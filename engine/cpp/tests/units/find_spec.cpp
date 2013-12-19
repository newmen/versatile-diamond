#include <generations/handbook.h>
#include <generations/builders/atom_builder.h>
#include <generations/phases/diamond.h>
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
        if (diamond->atom(crd))
        {
            Atom *atom = diamond->atom(crd);
            atom->activate();
            atom->changeType(24);
        }
        else
        {
            diamond->insert(builder.buildC(type, actives), crd);
        }
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

    // see at find_spec.png image for detailing test steps

    // 1
    buildBridge(0, 0, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 4 * 3600);

    // 2
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 0, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 3 * 3600 + 2000);

    // 3
    buildBridge(0, 1, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 7 * 3600 + 2000);

    // 4
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 1, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 6 * 3600 + 2 * 2000 + 1e5);

    // 5
    buildBridge(0, s.y - 1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, s.y - 1, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 9 * 3600 + 3 * 2000 + 2 * 1e5);

    // 6
    Handbook::mc().doOneOfOne(DIMER_FORMATION);
    printSeparator();
    assert(Handbook::mc().totalRate() == 9 * 3600 + 2000 + 5e3);

    // 7
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 0, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 8 * 3600 + 2 * 2000 + 5e3 + 1e7);

    // 8
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    printSeparator();
    assert(Handbook::mc().totalRate() == 8 * 3600 + 2000 + 3 * 38950);

    // 9
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 1, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 7 * 3600 + 2 * 2000 + 3 * 38950 + 1e7 + 1e6);

    // 10
    Handbook::mc().doOneOfOne(METHYL_ON_DIMER_HYDROGEN_MIGRATION);
    printSeparator();
    assert(Handbook::mc().totalRate() == 8 * 3600 + 2000 + 2 * 38950 + 3670 + 5e5);

    // 11
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    printSeparator();
    assert(Handbook::mc().totalRate() == 10 * 3600 + 2 * 2000 + 2 * 5e6);

    // 12
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, s.y - 1, 1);
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_ONE_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, s.y - 1, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 10 * 3600 + 2 * 2000 + 3.5e3 + 2.1e5);

    // 13
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 1, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 9 * 3600 + 3 * 2000 + 2 * 3.5e3 + 2.1e5);

    // 14
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, 0, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 10 * 3600 + 2 * 2000 + 3.5e3);

    // 15
    Handbook::mc().doOneOfOne(NEXT_LEVEL_BRIDGE_TO_HIGH_BRIDGE);
    printSeparator();
    assert(Handbook::mc().totalRate() == 10 * 3600 + 2 * 2000 + 5e6 + 1e5);

    // 16
    Handbook::mc().doOneOfOne(DIMER_FORMATION);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 0, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 9 * 3600 + 2000 + 5e3 + 1e7);

    // 17
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, s.y - 1, 1);
    Handbook::mc().doOneOfOne(METHYL_ON_DIMER_HYDROGEN_MIGRATION);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, s.y - 1, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 8 * 3600 + 2000 + 2 * 38950 + 3670 + 5e5 + 1e7 + 1e6);

    // 18
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    printSeparator();
    assert(Handbook::mc().totalRate() == 8 * 3600 + 5 * 38950 + 3670 + 5e5);

    // 19
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    printSeparator();
    assert(Handbook::mc().totalRate() == 13 * 3600 + 2000 + 1e4);

    // 20
    Handbook::mc().doOneOfOne(DES_METHYL_FROM_BRIDGE);
    printSeparator();
    assert(Handbook::mc().totalRate() == 10 * 3600 + 2 * 2000 + 5e6);

    // 21
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_ONE_BRIDGE);
    printSeparator();
    assert(Handbook::mc().totalRate() == 10 * 3600 + 2 * 2000 + 2 * 3.5e3 + 7.7e6);

    // 22
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_TWO_BRIDGES);
    printSeparator();
    assert(Handbook::mc().totalRate() == 10 * 3600 + 2 * 2000);

    // 23
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, s.y - 1, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 0, 2);
    printSeparator();
    assert(Handbook::mc().totalRate() == 8 * 3600 + 4 * 2000);

    // 24
    buildBridge(0, 2, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 2, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 11 * 3600 + 5 * 2000 + 2.1e5);

    // 25
    Handbook::mc().doOneOfOne(DIMER_FORMATION_NEAR_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 2, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 10 * 3600 + 4 * 2000 + 1e7);

    // 26
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    printSeparator();
    assert(Handbook::mc().totalRate() == 10 * 3600 + 3 * 2000 + 3 * 38950);

    // 27
    buildBridge(s.x - 1, 1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 1, 1, 1);
    buildBridge(s.x - 1, 2, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 1, 2, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 12 * 3600 + 5 * 2000 + 3 * 38950 + 2.6e5);

    // 28
    Handbook::mc().doOneOfOne(DIMER_FORMATION_AT_END);
    buildBridge(s.x - 2, 1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 2, 1, 1);
    buildBridge(s.x - 2, 2, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 2, 2, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 14 * 3600 + 5 * 2000 + 3 * 38950 + 2.6e5 + 4.9e3);

    // 29
    Handbook::mc().doOneOfOne(DIMER_FORMATION_AT_END);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 1, 2, 1);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    printSeparator();
    assert(Handbook::mc().totalRate() == 13 * 3600 + 4 * 2000 + 2 * 38950 + 3670 + 4.8e3 + 4.9e3 + 5e5 + 1e7);

    // 30
    Handbook::mc().doOneOfOne(DIMER_DROP_IN_MIDDLE);
    printSeparator();
    assert(Handbook::mc().totalRate() == 13 * 3600 + 6 * 2000 + 2 * 38950 + 3670 + 3.1e5 + 5e3 + 5e5);

    // 31
    Handbook::mc().doOneOfOne(DIMER_FORMATION_IN_MIDDLE);
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    printSeparator();
    assert(Handbook::mc().totalRate() == 15 * 3600 + 5 * 2000 + 2 * 4.9e3 + 7.7e6 + 1e7);

    // 32
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    printSeparator();
    assert(Handbook::mc().totalRate() == 15 * 3600 + 4 * 2000 + 3 * 38950 + 4.9e3 + 7.7e6);

    // 33
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_TWO_BRIDGES);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, 2, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 18 * 3600 + 4 * 2000 + 5e3 + 5e6);

    // 34
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_ONE_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 1, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 1, 1, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x - 1, 2, 1);
    printSeparator();
    assert(Handbook::mc().totalRate() == 17 * 3600 + 5 * 2000 + 5e3 + 1e5);

    // 35
    Handbook::mc().doOneOfOne(DIMER_FORMATION);
    printSeparator();
    assert(Handbook::mc().totalRate() == 17 * 3600 + 3 * 2000 + 2 * 5e3);

    delete diamond;
    return 0;
}
