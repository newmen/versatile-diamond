#include <generations/handbook.h>
#include <generations/builders/atom_builder.h>
#include <generations/crystals/diamond.h>
using namespace vd;

#include "../support/open_diamond.h"

#include <iostream>
using namespace std;

void printSeparator()
{
    cout << Handbook::mc().totalRate() << endl;
}

int main()
{
    cout.precision(20);

    const dim3 &s = OpenDiamond::SIZES;
    Diamond *diamond = new OpenDiamond(0);

    AtomBuilder builder;

    auto buildAtom = [&builder, diamond](const int3 &crd, ushort type, ushort actives) {
        assert(!diamond->atom(crd));
        diamond->insert(builder.buildC(type, actives), crd);
    };

    auto buildBridge = [&buildAtom, diamond](int x, int y, int z) {
        int3 crds[3] = {
            int3(x, y, z),
            int3(x, y, z - 1),
            int3(x, y, z - 1),
        };

        buildAtom(crds[0], 0, 2);
        buildAtom(crds[1], 4, 1);

        if (z % 2 == 0) crds[2].y += 1;
        else crds[2].x += 1;
        buildAtom(crds[2], 4, 1);

        Atom *atoms[3];
        for (int i = 0; i < 3; ++i)
        {
            atoms[i] = diamond->atom(crds[i]);
        }

        atoms[0]->bondWith(atoms[1]);
        atoms[0]->bondWith(atoms[2]);

        Finder::findAll(atoms, 3);
    };

    buildBridge(0, 0, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 4 * 3600);

    Handbook::mc().doOneOfMul<CORR_SURFACE_ACTIVATION>(0, 0, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 3 * 3600 + 2000);

    buildBridge(0, 1, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 7 * 3600 + 2000);

    Handbook::mc().doOneOfMul<CORR_SURFACE_ACTIVATION>(0, 1, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 6 * 3600 + 2 * 2000 + 1e5);

    buildBridge(0, s.y - 1, 1);
    Handbook::mc().doOneOfMul<CORR_SURFACE_ACTIVATION>(0, s.y - 1, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 9 * 3600 + 3 * 2000 + 2 * 1e5);

    Handbook::mc().doOneOfOne<DIMER_FORMATION>();
    printSeparator();
    assert(Handbook::mc().totalRate() == 9 * 3600 + 2000 + 5e4);

    Handbook::mc().doOneOfMul<CORR_SURFACE_ACTIVATION>(0, 0, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 8 * 3600 + 2 * 2000 + 5e4 + 1e7);

    Handbook::mc().doOneOfOne<ADS_METHYL_TO_DIMER>();
    printSeparator();
    assert(Handbook::mc().totalRate() == 8 * 3600 + 2000);

    Handbook::mc().doOneOfMul<CORR_SURFACE_ACTIVATION>(0, 1, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 7 * 3600 + 2 * 2000 + 1e7 + 1e6);

    Handbook::mc().doOneOfOne<METHYL_ON_DIMER_HYDROGEN_MIGRATION>();
    printSeparator();
    assert(Handbook::mc().totalRate() == 8 * 3600 + 2000 + 5e5);

    Handbook::mc().doOneOfOne<METHYL_TO_HIGH_BRIDGE>();
    printSeparator();
    assert(Handbook::mc().totalRate() == 10 * 3600 + 2 * 2000 + 2 * 5e6);

    Handbook::mc().doOneOfOne<HIGH_BRIDGE_STAND_TO_ONE_BRIDGE>();
    printSeparator();
    assert(Handbook::mc().totalRate() == 10 * 3600 + 2 * 2000 + 3.5e3 + 2.1e5);

    Handbook::mc().doOneOfMul<CORR_SURFACE_ACTIVATION>(0, 1, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 9 * 3600 + 3 * 2000 + 2 * 3.5e3 + 2.1e5);

    Handbook::mc().doOneOfMul<CORR_SURFACE_DEACTIVATION>(0, 0, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 10 * 3600 + 2 * 2000 + 3.5e3);

    Handbook::mc().doOneOfOne<NEXT_LEVEL_BRIDGE_TO_HIGH_BRIDGE>();
    printSeparator();
    assert(Handbook::mc().totalRate() == 10 * 3600 + 2 * 2000 + 5e6 + 1e5);

    Handbook::mc().doOneOfOne<DIMER_FORMATION>();
    Handbook::mc().doOneOfMul<CORR_SURFACE_ACTIVATION>(0, 0, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 9 * 3600 + 2000 + 5e4 + 1e7);

    Handbook::mc().doOneOfOne<ADS_METHYL_TO_DIMER>();
    Handbook::mc().doOneOfMul<CORR_SURFACE_ACTIVATION>(0, s.y - 1, 1);
    Handbook::mc().doOneOfOne<METHYL_ON_DIMER_HYDROGEN_MIGRATION>();
    Handbook::mc().doOneOfMul<CORR_SURFACE_ACTIVATION>(0, s.y - 1, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 8 * 3600 + 2000 + 5e5 + 1e7 + 1e6);

    Handbook::mc().doOneOfOne<ADS_METHYL_TO_DIMER>();
    printSeparator();
    assert(Handbook::mc().totalRate() == 8 * 3600 + 5e5);

    Handbook::mc().doOneOfOne<METHYL_TO_HIGH_BRIDGE>();
    printSeparator();
    assert(Handbook::mc().totalRate() == 10 * 3600 + 2000 + 1e4);

    Handbook::mc().doOneOfOne<DES_METHYL_FROM_BRIDGE>();
    printSeparator();
    assert(Handbook::mc().totalRate() == 10 * 3600 + 2 * 2000 + 5e6);

    Handbook::mc().doOneOfOne<HIGH_BRIDGE_STAND_TO_ONE_BRIDGE>();
    printSeparator();
    assert(Handbook::mc().totalRate() == 10 * 3600 + 2 * 2000 + 2 * 3.5e3 + 7.7e6);

    Handbook::mc().doOneOfOne<HIGH_BRIDGE_STAND_TO_TWO_BRIDGES>();
    printSeparator();
    assert(Handbook::mc().totalRate() == 10 * 3600 + 2 * 2000); // + 2 * 3.5e3

    Handbook::mc().doOneOfMul<CORR_SURFACE_ACTIVATION>(0, s.y - 1, 2);
    Handbook::mc().doOneOfMul<CORR_SURFACE_ACTIVATION>(0, 0, 2);
    printSeparator();
    assert(Handbook::mc().totalRate() == 8 * 3600 + 4 * 2000); // + 2 * 3.5e3

    delete diamond;
    return 0;
}
