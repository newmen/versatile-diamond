#include <omp.h>
#include <iostream>
#include "mc/common_mc_data.h"
#include "generations/handbook.h"
#include "generations/phases/diamond.h"

#ifdef PRINT
void printSeparator()
{
    debugPrint([&](std::ostream &os) {
        os << Handbook::mc().totalRate();
    });
}
#endif // PRINT

int main()
{
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

//    Diamond *diamond = new Diamond(dim3(100, 100, 50));
    Diamond *diamond = new Diamond(dim3(20, 20, 50));
//    Diamond *diamond = new Diamond(dim3(3, 3, 4));
    diamond->initialize();

    std::cout << "Begin atoms num: " << diamond->countAtoms() << "\n" << std::endl;

#ifdef PRINT
    printSeparator();
#endif // PRINT

    uint n = 0;
    CommonMCData mcData;
    Handbook::mc().initCounter(&mcData);

#ifdef PARALLEL
#pragma omp parallel
#endif // PARALLEL
//    for (uint i = 0; i < 50000 / THREADS_NUM; ++i)
    while (Handbook::mc().totalTime() < 4e-4)
//    while (Handbook::mc().totalTime() < 2e-2)
    {
        Handbook::mc().doRandom(&mcData);

#ifdef PRINT
        debugPrint([&](std::ostream &os) {
            os << n << ". " << Handbook::mc().totalRate() << "\n";
        });
#endif // PRINT

#ifdef PARALLEL
#pragma omp critical
#endif // PARALLEL
        {
            ++n;

            if (n == 1000000)
            {
                std::cout.width(20);
                std::cout << Handbook::mc().totalTime() << " (s)";
                std::cout.width(20);
                std::cout << Handbook::mc().totalRate() << " (1/s)" << std::endl;
		n = 0;
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
