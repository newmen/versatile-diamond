#include <generations/handbook.h>
#include <generations/crystals/diamond.h>
using namespace vd;

#include "../support/open_diamond.h"

#include <iostream>
using namespace std;

int main(int argc, char const *argv[])
{
    const dim3 &s = OpenDiamond::SIZES;

    const double initValue = s.x * s.y * (1e5 + 3600 + 2000);

    Diamond *diamond = new OpenDiamond(2);
    diamond->initialize();
    cout << Handbook::mc.totalRate() << endl;
    assert(Handbook::mc.totalRate() == initValue);

    Handbook::mc.doOneOfOne<DIMER_FORMATION>();
    cout << Handbook::mc.totalRate() << endl;
    assert(Handbook::mc.totalRate() == initValue - 3e5 + 5e4 - 2 * 2000);

    Handbook::mc.doOneOfOne<DIMER_DROP>();
    cout << Handbook::mc.totalRate() << endl;
    assert(Handbook::mc.totalRate() == initValue);

    int n = 0;
    for (int x = 0; x < s.x; ++x)
        for (int y = 0; y < s.y; ++y)
        {
            Handbook::mc.doOneOfMul<SURFACE_ACTIVATION>();
            assert(Handbook::mc.totalRate() == initValue - (++n) * (3600 - 2000));
        }

    const double allActivesValue = s.x * s.y * (1e5 + 2 * 2000);

    Handbook::mc.doOneOfMul<SURFACE_DEACTIVATION>();
    cout << Handbook::mc.totalRate() << endl;
    assert(Handbook::mc.totalRate() == allActivesValue + (3600 - 2000));

    Handbook::mc.doOneOfMul<SURFACE_ACTIVATION>();
    cout << Handbook::mc.totalRate() << endl;
    assert(Handbook::mc.totalRate() == allActivesValue);

    Handbook::mc.doOneOfOne<DIMER_FORMATION>();
    cout << Handbook::mc.totalRate() << endl;
    assert(Handbook::mc.totalRate() == allActivesValue + 2e7 - 3e5 + 5e4 - 2 * 2000);

    Handbook::mc.doOneOfOne<METHYL_TO_DIMER>();
    cout << Handbook::mc.totalRate() << endl;
    assert(Handbook::mc.totalRate() == allActivesValue + 1e7 - 3e5 - 3 * 2000);


    delete diamond;
    return 0;
}
