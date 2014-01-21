#include <signal.h>
#include <omp.h>
#include <iostream>
#include "mc/common_mc_data.h"
#include "tools/saver/mol_saver.h"
#include "generations/handbook.h"
#include "generations/phases/diamond.h"

volatile bool stopCalculating = false;
void stopSignalHandler(int)
{
#ifdef PARALLEL
#pragma omp master
#endif // PARALLEL
    stopCalculating = true;
}

void segfaultSignalHandler(int)
{
#ifdef PARALLEL
#pragma omp master
#endif // PARALLEL
    std::cout << "Segmentation fault signal recived! Stop computing..." << std::endl;

    exit(1);
}

#ifdef PRINT
void printSeparator()
{
    debugPrint([&](std::ostream &os) {
        os << Handbook::mc().totalRate();
    });
}
#endif // PRINT

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        std::cerr << "Wrong number of argument!" << std::endl;
        std::cout << "Try: " << argv[0] << " run_name" << std::endl;
        return 1;
    }

    const char *runName = argv[1];

    signal(SIGINT, stopSignalHandler);
    signal(SIGTERM, stopSignalHandler);
#ifndef PARALLEL
    signal(SIGSEGV, segfaultSignalHandler);
#endif // PARALLEL
    std::cout.precision(3); // for outputs in main loop

    RandomGenerator::init(); // it must be called just one time at program begin (before init CommonMCData!)

#ifdef PARALLEL
    omp_set_num_threads(THREADS_NUM);
#endif // PARALLEL

#ifdef PRINT
    debugPrint([&](std::ostream &os) {
#ifdef PARALLEL
        os << "Start as PARALLEL mode";
#else
        os << "Start as SINGLE THREAD mode";
#endif // PARALLEL
    });
#endif // PRINT

// ------------------------------------------------------------------------------------------------------------------ //

    double totalTime = 60;

    Diamond *diamond = new Diamond(dim3(100, 100, 50));
//    Diamond *diamond = new Diamond(dim3(20, 20, 2000));
    diamond->initialize();

// ------------------------------------------------------------------------------------------------------------------ //

    std::cout << "Begin atoms num: " << diamond->countAtoms() << "\n" << std::endl;

#ifdef PRINT
    printSeparator();
#endif // PRINT

    ullong n = 0;
    CommonMCData mcData;
    Handbook::mc().initCounter(&mcData);

    MolSaver saver(runName);

#ifdef PARALLEL
#pragma omp parallel
#endif // PARALLEL
    while (!stopCalculating && Handbook::mc().totalTime() < totalTime)
    {
        Handbook::mc().doRandom(&mcData);
        if (stopCalculating) break;

#ifdef PRINT
        debugPrint([&](std::ostream &os) {
            os << n << ". " << Handbook::mc().totalRate() << "\n";
        });
#endif // PRINT

#ifdef PARALLEL
#pragma omp critical
#endif // PARALLEL
        {
            if (++n % 10000000 == 0)
            {
                std::cout.width(10);
                std::cout << Handbook::mc().totalTime() / totalTime << " %";
                std::cout.width(10);
                std::cout << diamond->countAtoms();
                std::cout.width(10);
                std::cout << Handbook::amorph().countAtoms();
                std::cout.width(20);
                std::cout << Handbook::mc().totalTime() << " (s)";
                std::cout.width(20);
                std::cout << Handbook::mc().totalRate() << " (1/s)" << std::endl;

                Handbook::amorph().setUnvisited();
                diamond->setUnvisited();
                saver.writeFrom(diamond->firstAtom());
#ifndef NDEBUG
                Handbook::amorph().checkAllVisited();
                diamond->checkAllVisited();
#endif // NDEBUG
            }
        }
    }

    std::cout << "\nEnd atoms num: " << diamond->countAtoms() << "\n"
              << "Rejected events rate: " << 100 * (1 - (double)mcData.counter()->total() / n) << " %\n"
              << std::endl;
    mcData.counter()->printStats();

    Handbook::amorph().clear(); // TODO: should not be explicitly!
    delete diamond;
    return 0;
}
