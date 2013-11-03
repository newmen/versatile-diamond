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
    cout.precision(20);
    cout << Handbook::mc.totalRate() << endl;
    assert(Handbook::mc.totalRate() == initValue);

    Handbook::mc.doOneOfOne<DIMER_FORMATION>();
    cout.precision(20);
    cout << Handbook::mc.totalRate() << endl;
    assert(Handbook::mc.totalRate() == initValue - 3e5 + 5e4 - 2 * 2000);

    Handbook::mc.doOneOfOne<DIMER_DROP>();
    cout.precision(20);
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
    cout.precision(20);
    cout << Handbook::mc.totalRate() << endl;
    assert(Handbook::mc.totalRate() == allActivesValue + (3600 - 2000));

    Handbook::mc.doOneOfMul<SURFACE_ACTIVATION>();
    cout.precision(20);
    cout << Handbook::mc.totalRate() << endl;
    assert(Handbook::mc.totalRate() == allActivesValue);

    Handbook::mc.doOneOfOne<DIMER_FORMATION>();
    cout.precision(20);
    cout << Handbook::mc.totalRate() << endl;
    assert(Handbook::mc.totalRate() == allActivesValue + 2e7 - 3e5 + 5e4 - 2 * 2000);

    Handbook::mc.doOneOfOne<ADS_METHYL_TO_DIMER>();
    cout.precision(20);
    cout << Handbook::mc.totalRate() << endl;
    assert(Handbook::mc.totalRate() == allActivesValue + 1e7 + 1e6 - 3e5 - 3 * 2000);

    Handbook::mc.doOneOfOne<METHYL_ON_DIMER_HYDROGEN_MIGRATION>();
    cout.precision(20);
    cout << Handbook::mc.totalRate() << endl;
    assert(Handbook::mc.totalRate() == allActivesValue + 5e5 - 3e5 + 3600 - 4 * 2000);

    Handbook::mc.doOneOfOne<METHYL_TO_HIGH_BRIDGE>();
    cout.precision(20);
    cout << Handbook::mc.totalRate() << endl;
    assert(Handbook::mc.totalRate() == allActivesValue - 3e5 + 3 * 3600 - 3 * 2000);

    delete diamond;
    return 0;
}
