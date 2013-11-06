#include "generations/handbook.h"
#include "generations/crystals/diamond.h"

#include "tests/support/open_diamond.h"

#include <iostream>
using namespace std;
#ifdef PRINT
#endif // PRINT

int main()
{
#ifdef PRINT
#ifdef PARALLEL
    cout << "Start as PARALLEL mode" << endl;
#endif // PARALLEL

#ifndef PARALLEL
    cout << "Start as SINGLE THREAD mode" << endl;
#endif // PARALLEL
#endif // PRINT

    Diamond *diamond = new Diamond(dim3(100, 100, 10));
//    Diamond *diamond = new Diamond(dim3(5, 5, 4), 2);
    diamond->initialize();

    cout << "Atoms num: " << diamond->countAtoms() << endl;
#ifdef PRINT
    cout << Handbook::mc.totalRate() << endl;
#endif // PRINT

    for (int i = 0; i < 1000000; ++i)
    {
        Handbook::mc.doRandom();

#ifdef PRINT
        cout << i << ". " << Handbook::mc.totalRate() << "\n\n\n" << endl;
#endif // PRINT
    }

#ifdef PRINT
#endif // PRINT
    cout << "Atoms num: " << diamond->countAtoms() << endl;

    delete diamond;
    return 0;
}
