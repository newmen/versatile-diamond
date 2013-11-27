#include <omp.h>
#include <iostream>

#include "mc/common_mc_data.h"
#include "generations/handbook.h"
#include "generations/builders/atom_builder.h"
#include "generations/crystals/diamond.h"

#include "tests/support/open_diamond.h"

#ifdef PRINT
#include "tools/debug_print.h"

void printSeparator()
{
    debugPrint([&](std::ostream &os) {
        os << Handbook::mc().totalRate();
    });
}
#endif // PRINT

int main()
{
#ifdef PARALLEL
    omp_set_num_threads(THREADS_NUM);
#endif // PARALLEL

#ifdef PRINT
#ifdef PARALLEL
    debugPrint([&](std::ostream &os) {
        os << "Start as PARALLEL mode";
    });
#else
    debugPrint([&](std::ostream &os) {
        os << "Start as SINGLE THREAD mode";
    });
#endif // PARALLEL
#endif // PRINT

//    Diamond *diamond = new Diamond(dim3(100, 100, 10));
    Diamond *diamond = new Diamond(dim3(20, 20, 10));
//    Diamond *diamond = new Diamond(dim3(3, 3, 4));
    diamond->initialize();

    std::cout << "Atoms num: " << diamond->countAtoms() << std::endl;

#ifdef PRINT
    printSeparator();
    int i = 0;
#endif // PRINT

    RandomGenerator::init(); // it must be called just one time (before init CommonMCData)
    CommonMCData mcData;
    Handbook::mc().initCounter(&mcData);

#ifdef PARALLEL
#pragma omp parallel
#endif // PARALLEL
//    for (int i = 0; i < 500000; ++i)
    while (Handbook::mc().totalTime() < 0.5)
    {
        Handbook::mc().doRandom(&mcData);

#ifdef PRINT
        debugPrint([&](std::ostream &os) {
            os << (++i) << ". " << Handbook::mc().totalRate() << "\n\n\n";
        });
#endif // PRINT
    }

    std::cout << "Atoms num: " << diamond->countAtoms() << "\n" << std::endl;
    mcData.counter()->printStats();

    delete diamond;
    return 0;
}
