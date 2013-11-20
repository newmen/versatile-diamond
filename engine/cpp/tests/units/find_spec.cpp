#include <generations/handbook.h>
#include <generations/crystals/diamond.h>
using namespace vd;

#include "../support/open_diamond.h"

#include <iostream>
using namespace std;

int main()
{
    cout.precision(20);

    const dim3 &s = OpenDiamond::SIZES;

    const double initValue = s.x * s.y * (1e5 + 3600 + 2000);
    cout << "Initial rate: " << initValue << endl;

    Diamond *diamond = new OpenDiamond(2);
    diamond->initialize();
    cout << Handbook::mc().totalRate() << endl;
    assert(Handbook::mc().totalRate() == initValue);

    Handbook::mc().doOneOfOne<DIMER_FORMATION>();
    cout << Handbook::mc().totalRate() << endl;
    assert(Handbook::mc().totalRate() == initValue - 3 * 1e5 + 5e4 - 2 * 2000);

    Handbook::mc().doOneOfOne<DIMER_DROP>();
    cout << Handbook::mc().totalRate() << endl;
    assert(Handbook::mc().totalRate() == initValue);

    // activates all surface carbons
    uint n = 0;
    for (uint x = 0; x < s.x; ++x)
        for (uint y = 0; y < s.y; ++y)
        {
            Handbook::mc().doOneOfMul<SURFACE_ACTIVATION>();
            assert(Handbook::mc().totalRate() == initValue - (++n) * (3600 - 2000));
        }

    const double allActivesValue = s.x * s.y * (1e5 + 2 * 2000);

    Handbook::mc().doOneOfMul<SURFACE_DEACTIVATION>();
    cout << Handbook::mc().totalRate() << endl;
    assert(Handbook::mc().totalRate() == allActivesValue + (3600 - 2000));

    Handbook::mc().doOneOfMul<SURFACE_ACTIVATION>();
    cout << Handbook::mc().totalRate() << endl;
    assert(Handbook::mc().totalRate() == allActivesValue);

    Handbook::mc().doOneOfOne<DIMER_FORMATION>();
    cout << Handbook::mc().totalRate() << endl;
    assert(Handbook::mc().totalRate() == allActivesValue + 2 * 1e7 - 3 * 1e5 + 5e4 - 2 * 2000);

    Handbook::mc().doOneOfOne<ADS_METHYL_TO_DIMER>();
    cout << Handbook::mc().totalRate() << endl;
    assert(Handbook::mc().totalRate() == allActivesValue + 1e7 + 1e6 - 3 * 1e5 - 3 * 2000);

    Handbook::mc().doOneOfOne<METHYL_ON_DIMER_HYDROGEN_MIGRATION>();
    cout << Handbook::mc().totalRate() << endl;
    assert(Handbook::mc().totalRate() == allActivesValue + 5e5 - 3 * 1e5 + 3600 - 4 * 2000);

    Handbook::mc().doOneOfMul<SURFACE_ACTIVATION>();
    cout << Handbook::mc().totalRate() << endl;
    assert(Handbook::mc().totalRate() == allActivesValue + 1e7 + 1e6 + 5e5 - 3 * 1e5 - 3 * 2000);

    Handbook::mc().doOneOfOne<ADS_METHYL_TO_DIMER>();
    cout << Handbook::mc().totalRate() << endl;
    assert(Handbook::mc().totalRate() == allActivesValue + 5e5 - 3 * 1e5 - 4 * 2000);

    Handbook::mc().doOneOfOne<METHYL_TO_HIGH_BRIDGE>();
    cout << Handbook::mc().totalRate() << endl;
    assert(Handbook::mc().totalRate() == allActivesValue + 5e6 - 3 * 1e5 + 1e4 + 2 * 3600 - 3 * 2000);

    Handbook::mc().doOneOfOne<DES_METHYL_FROM_BRIDGE>();
    cout << Handbook::mc().totalRate() << endl;
    assert(Handbook::mc().totalRate() == allActivesValue + 2 * 5e6 - 2 * 1e5 + 2 * 3600 - 2 * 2000);

    Handbook::mc().doOneOfOne<HIGH_BRIDGE_STAND_TO_ONE_BRIDGE>();
    cout << Handbook::mc().totalRate() << endl;
    assert(Handbook::mc().totalRate() == allActivesValue + 2 * 3.5e3 - 3 * 1e5 + 2 * 3600 - 2 * 2000);

    Handbook::mc().doOneOfOne<NEXT_LEVEL_BRIDGE_TO_HIGH_BRIDGE>();
    cout << Handbook::mc().totalRate() << endl;
    assert(Handbook::mc().totalRate() == allActivesValue + 2 * 5e6 - 2 * 1e5 + 2 * 3600 - 2 * 2000);

    delete diamond;
    return 0;
}
