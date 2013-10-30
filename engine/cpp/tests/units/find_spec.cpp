#include <generations/handbook.h>
#include <generations/crystals/diamond.h>
using namespace vd;

#include "../support/open_diamond.h"

#include <iostream>
using namespace std;

int main(int argc, char const *argv[])
{
    Diamond *diamond = new OpenDiamond(2);
    diamond->initialize();
    assert(Handbook::mc().totalRate() == 1056000000);

    Handbook::mc().doOneOfMul<SURFACE_ACTIVATION>();
    assert(Handbook::mc().totalRate() == 1055998400);

    Handbook::mc().doOneOfMul<SURFACE_DEACTIVATION>();
    assert(Handbook::mc().totalRate() == 1056000000);

    Handbook::mc().doOneOfOne<DIMER_FORMATION>();
    cout << Handbook::mc().totalRate() << endl;
    assert(Handbook::mc().totalRate() == 1055746000);

    Handbook::mc().doOneOfOne<DIMER_DROP>();
    assert(Handbook::mc().totalRate() == 1056000000);

    delete diamond;
    return 0;
}
