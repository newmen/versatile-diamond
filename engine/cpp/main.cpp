#include "generations/handbook.h"
#include "generations/crystals/diamond.h"

#include "tests/support/open_diamond.h"

#ifdef PARALLEL
#include <omp.h>
#endif // PARALLEL

#ifdef PRINT
#include <iostream>
using namespace std;
#endif // PRINT

int main()
{
#ifdef PRINT
#ifdef PARALLEL
//    omp_set_num_threads(1);
    cout << "Start as PARALLEL mode" << endl;
#endif // PARALLEL

#ifndef PARALLEL
//    omp_set_num_threads(1);
    cout << "Start as SINGLE THREAD mode" << endl;
#endif // PARALLEL
#endif // PRINT

//    Diamond *diamond = new OpenDiamond(2);
//    Diamond *diamond = new Diamond(dim3(100, 100, 20), 10);
    Diamond *diamond = new Diamond(dim3(3, 3, 3), 2);
    diamond->initialize();

#ifdef PRINT
    cout << Handbook::mc().totalRate() << endl;
#endif // PRINT

    for (int i = 0; i < 8000; ++i)
//    for (int i = 0; i < 100000; ++i)
    {
        Handbook::mc().doRandom();

#ifdef PRINT
        cout << i << ". " << Handbook::mc().totalRate() << "\n\n\n" << endl;
#endif // PRINT
    }

    delete diamond;
    return 0;
}
