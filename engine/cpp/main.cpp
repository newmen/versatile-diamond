#include "generations/handbook.h"
#include "generations/crystals/diamond.h"

#include "tests/support/open_diamond.h"

#ifdef PARALLEL
#include <omp.h>
#endif // PARALLEL

#include <iostream>
using namespace std;

int main()
{
#ifdef PARALLEL
//    omp_set_num_threads(1);
    cout << "Start as PARALLEL mode" << endl;
#endif // PARALLEL

#ifndef PARALLEL
//    omp_set_num_threads(1);
    cout << "Start as SINGLE THREAD mode" << endl;
#endif // PARALLEL

//    Diamond *diamond = new OpenDiamond(2);
    Diamond *diamond = new Diamond(dim3(100, 100, 20), 10);
//    Diamond *diamond = new Diamond(dim3(4, 4, 4), 2);
    diamond->initialize();

    cout << Handbook::mc().totalRate() << endl;

//    for (int i = 0; i < 8; ++i)
    for (int i = 0; i < 10000; ++i)
    {
        cout << i << ". ";
        Handbook::mc().doRandom();
        cout << Handbook::mc().totalRate() << endl;
    }

//    Handbook::mc().doOneOfMul<SURFACE_ACTIVATION>();
//    cout << Handbook::mc().totalRate() << endl;

//    Handbook::mc().doOneOfMul<SURFACE_DEACTIVATION>();
//    cout << Handbook::mc().totalRate() << endl;

//    Handbook::mc().doOneOfOne<DIMER_FORMATION>();
//    cout << Handbook::mc().totalRate() << endl;

    delete diamond;
    return 0;
}
