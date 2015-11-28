// See at find_spec.png image for detailing test steps

#include <handbook.h>
#include <atoms/atom_builder.h>
#include <phases/diamond.h>

#include <reactions/central/dimer_drop.h>
#include <reactions/central/dimer_formation.h>
#include <reactions/lateral/dimer_drop_at_end.h>
#include <reactions/lateral/dimer_drop_in_middle.h>
#include <reactions/lateral/dimer_formation_at_end.h>
#include <reactions/lateral/dimer_formation_in_middle.h>
#include <reactions/typical/abs_hydrogen_from_gap.h>
#include <reactions/typical/ads_methyl_to_111.h>
#include <reactions/typical/ads_methyl_to_dimer.h>
#include <reactions/typical/bridge_with_dimer_to_high_bridge_and_dimer.h>
#include <reactions/typical/des_methyl_from_111.h>
#include <reactions/typical/des_methyl_from_bridge.h>
#include <reactions/typical/des_methyl_from_dimer.h>
#include <reactions/typical/dimer_drop_near_bridge.h>
#include <reactions/typical/dimer_formation_near_bridge.h>
#include <reactions/typical/form_two_bond.h>
#include <reactions/typical/high_bridge_stand_to_dimer.h>
#include <reactions/typical/high_bridge_stand_to_one_bridge.h>
#include <reactions/typical/high_bridge_to_methyl.h>
#include <reactions/typical/high_bridge_to_two_bridges.h>
#include <reactions/typical/lookers/near_activated_dimer.h>
#include <reactions/typical/lookers/near_gap.h>
#include <reactions/typical/lookers/near_high_bridge.h>
#include <reactions/typical/lookers/near_methyl_on_111.h>
#include <reactions/typical/lookers/near_methyl_on_bridge.h>
#include <reactions/typical/lookers/near_methyl_on_bridge_cbi.h>
#include <reactions/typical/lookers/near_methyl_on_dimer.h>
#include <reactions/typical/lookers/near_part_of_gap.h>
#include <reactions/typical/methyl_on_dimer_hydrogen_migration.h>
#include <reactions/typical/methyl_to_high_bridge.h>
#include <reactions/typical/migration_down_at_dimer.h>
#include <reactions/typical/migration_down_at_dimer_from_111.h>
#include <reactions/typical/migration_down_at_dimer_from_dimer.h>
#include <reactions/typical/migration_down_at_dimer_from_high_bridge.h>
#include <reactions/typical/migration_down_in_gap.h>
#include <reactions/typical/migration_down_in_gap_from_111.h>
#include <reactions/typical/migration_down_in_gap_from_dimer.h>
#include <reactions/typical/migration_down_in_gap_from_high_bridge.h>
#include <reactions/typical/migration_through_dimers_row.h>
#include <reactions/typical/next_level_bridge_to_high_bridge.h>
#include <reactions/typical/sierpinski_drop.h>
#include <reactions/typical/two_bridges_to_high_bridge.h>
#include <reactions/ubiquitous/local/methyl_on_dimer_activation.h>
#include <reactions/ubiquitous/local/methyl_on_dimer_deactivation.h>
#include <reactions/ubiquitous/surface_activation.h>
#include <reactions/ubiquitous/surface_deactivation.h>

#include "../support/open_diamond.h"

#include <iostream>
using namespace std;

void assert_rate(double rate)
{
    static const double EPS = 1e-2;
    double delta = Handbook::mc().totalRate() - rate;

    // static int counter = 1;
    // cout << (counter++) << "\tdelta: " << delta << "\trate: " << rate << endl;

    assert(abs(delta) < EPS);
}

void assert_atom_state(const Atom *atom, ushort bonds, ushort actives)
{
    assert(atom->bonds() == bonds);
    assert(atom->actives() == actives);
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
        Atom *anchors[3];
        uint anchorsCounter = 0;
        for (int i = 0; i < 3; ++i)
        {
            atoms[i] = diamond->atom(crds[i]);
            if (crds[i].z > 0)
            {
                anchors[i] = atoms[i];
                ++anchorsCounter;
            }
        }

        atoms[0]->bondWith(atoms[1]);
        atoms[0]->bondWith(atoms[2]);

        Finder::findAll(anchors, anchorsCounter);
    };

    auto assert_atom = [diamond](int x, int y, int z, ushort bonds, ushort actives) {
        Atom *atom = diamond->atom(int3(x, y, z));
        assert_atom_state(atom, bonds, actives);
    };

    auto assert_amorph_atom = [diamond](int x, int y, int z, ushort bonds, ushort actives) {
        Atom *crystalAtom = diamond->atom(int3(x, y, z));
        Atom *atom = crystalAtom->amorphNeighbour();
        assert_atom_state(atom, bonds, actives);
    };

    // 1
    buildBridge(0, 0, 1);
    assert_rate(2 * SurfaceActivation::RATE());
    assert_atom(0, 0, 0, 1, 0);
    assert_atom(1, 0, 0, 1, 0);
    assert_atom(0, 0, 1, 2, 0);

    // 2
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 0, 1);
    assert_rate(SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE());
    assert_atom(0, 0, 1, 2, 1);

    // 3
    buildBridge(0, 1, 1);
    assert_rate(3 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE());
    assert_atom(0, 1, 0, 1, 0);
    assert_atom(1, 1, 0, 1, 0);
    assert_atom(0, 1, 1, 2, 0);

    // 4
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 1, 1);
    assert_rate(2 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                DimerFormation::RATE());
    assert_atom(0, 1, 1, 2, 1);

    // 5
    buildBridge(0, s.y-1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, s.y-1, 1);
    assert_rate(3 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                2 * DimerFormation::RATE());
    assert_atom(0, s.y-1, 0, 1, 0);
    assert_atom(1, s.y-1, 0, 1, 0);
    assert_atom(0, s.y-1, 1, 2, 1);

    // 6
    Handbook::mc().doOneOfOne(DIMER_FORMATION);
    assert_rate(3 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                DimerDrop::RATE());
    assert_atom(0, 0, 1, 3, 0);
    assert_atom(0, 1, 1, 3, 0);

    // 7
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 0, 1);
    assert_rate(2 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                DimerDrop::RATE() +
                AdsMethylToDimer::RATE());
    assert_atom(0, 0, 1, 3, 1);

    // 8
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    assert_rate(2 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                3 * MethylOnDimerActivation::RATE() +
                DesMethylFromDimer::RATE());
    assert_atom(0, 0, 1, 4, 0);
    assert_amorph_atom(0, 0, 1, 1, 0);

    // 9
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 1, 1);
    assert_rate(SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                3 * MethylOnDimerActivation::RATE() +
                AdsMethylToDimer::RATE() +
                MethylOnDimerHydrogenMigration::RATE() +
                DesMethylFromDimer::RATE());
    assert_atom(0, 1, 1, 3, 1);

    // 10
    Handbook::mc().doOneOfOne(METHYL_ON_DIMER_HYDROGEN_MIGRATION);
    assert_rate(2 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                2 * MethylOnDimerActivation::RATE() +
                MethylOnDimerDeactivation::RATE() +
                MethylToHighBridge::RATE() +
                DesMethylFromDimer::RATE());
    assert_atom(0, 1, 1, 3, 0);
    assert_amorph_atom(0, 0, 1, 1, 1);

    // 11
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    assert_rate(4 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                2 * HighBridgeStandToOneBridge::RATE() +
                2 * HighBridgeToMethyl::RATE());
    assert_atom(0, 1, 1, 2, 1);
    assert_atom(0, 0, 1, 4, 0);
    assert_amorph_atom(0, 0, 1, 2, 0);

    // 12
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, s.y-1, 1);
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_ONE_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, s.y-1, 1);
    assert_rate(4 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                NextLevelBridgeToHighBridge::RATE() +
                DimerFormationNearBridge::RATE() +
                AdsMethylTo111::RATE());
    assert_atom(0, s.y-1, 1, 2, 1);
    assert_atom(0, 1, 1, 3, 0);
    assert_atom(0, 0, 1, 3, 1);
    assert_atom(0, 0, 2, 2, 0);

    // 13
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 1, 1);
    assert_rate(3 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                2 * NextLevelBridgeToHighBridge::RATE() +
                2 * AdsMethylTo111::RATE() +
                DimerFormationNearBridge::RATE());
    assert_atom(0, 1, 1, 3, 1);

    // 14
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, 0, 1);
    assert_rate(4 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                NextLevelBridgeToHighBridge::RATE() +
                AdsMethylTo111::RATE());
    assert_atom(0, 0, 1, 3, 0);

    // 15
    Handbook::mc().doOneOfOne(NEXT_LEVEL_BRIDGE_TO_HIGH_BRIDGE);
    assert_rate(4 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                HighBridgeStandToOneBridge::RATE() +
                DimerFormation::RATE() +
                HighBridgeToMethyl::RATE());
    assert_atom(0, 0, 1, 2, 1);
    assert_atom(0, 1, 1, 4, 0);
    assert_amorph_atom(0, 1, 1, 2, 0);

    // 16
    Handbook::mc().doOneOfOne(DIMER_FORMATION);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 0, 1);
    assert_rate(3 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                DimerDrop::RATE() +
                AdsMethylToDimer::RATE() +
                HighBridgeStandToDimer::RATE());
    assert_atom(0, s.y-1, 1, 3, 0);
    assert_atom(0, 0, 1, 3, 1);

    // 17
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, s.y-1, 1);
    Handbook::mc().doOneOfOne(METHYL_ON_DIMER_HYDROGEN_MIGRATION);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, s.y-1, 1);
    assert_rate(2 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                2 * MethylOnDimerActivation::RATE() +
                MethylOnDimerDeactivation::RATE() +
                MethylToHighBridge::RATE() +
                AdsMethylToDimer::RATE() +
                MethylOnDimerHydrogenMigration::RATE() +
                DesMethylFromDimer::RATE());
    assert_atom(0, s.y-1, 1, 3, 1);
    assert_atom(0, 0, 1, 4, 0);
    assert_amorph_atom(0, 0, 1, 1, 1);

    // 18
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    assert_rate(2 * SurfaceActivation::RATE() +
                5 * MethylOnDimerActivation::RATE() +
                2 * DesMethylFromDimer::RATE() +
                MethylOnDimerDeactivation::RATE() +
                MethylToHighBridge::RATE());
    assert_atom(0, s.y-1, 1, 4, 0);
    assert_amorph_atom(0, s.y-1, 1, 1, 0);

    // 19
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    assert_rate(7 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                DesMethylFromBridge::RATE());
    assert_atom(0, s.y-1, 1, 3, 1);
    assert_atom(0, 0, 1, 4, 0);
    assert_amorph_atom(0, 0, 1, 2, 0);

    // 20
    Handbook::mc().doOneOfOne(DES_METHYL_FROM_BRIDGE);
    assert_rate(4 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                HighBridgeStandToOneBridge::RATE() +
                HighBridgeToMethyl::RATE());
    assert_atom(0, s.y-1, 1, 2, 2);

    // 21
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_ONE_BRIDGE);
    assert_rate(4 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                2 * NextLevelBridgeToHighBridge::RATE() +
                2 * AdsMethylTo111::RATE() +
                HighBridgeToTwoBridges::RATE() +
                HighBridgeToMethyl::RATE());
    assert_atom(0, s.y-1, 2, 2, 0);
    assert_atom(0, s.y-1, 1, 3, 1);
    assert_atom(0, 0, 1, 3, 1);

    // 22
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_TWO_BRIDGES);
    assert_rate(4 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                2 * TwoBridgesToHighBridge::RATE() +
                2 * AdsMethylTo111::RATE());
    assert_atom(0, 0, 2, 2, 0);
    assert_atom(0, 0, 1, 4, 0);
    assert_atom(0, 1, 1, 3, 1);

    // 23
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, s.y-1, 1);
    assert_rate(5 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                TwoBridgesToHighBridge::RATE() +
                AdsMethylTo111::RATE());
    assert_atom(0, s.y-1, 1, 3, 0);

    // 24
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, s.y-1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, s.y-1, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 0, 2);
    assert_rate(2 * SurfaceActivation::RATE() +
                4 * SurfaceDeactivation::RATE() +
                2 * TwoBridgesToHighBridge::RATE() +
                2 * AdsMethylTo111::RATE());
    assert_atom(0, s.y-1, 1, 3, 1);
    assert_atom(0, s.y-1, 2, 2, 1);
    assert_atom(0, 0, 2, 2, 1);

    // 25
    buildBridge(0, 2, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 2, 1);
    assert_rate(3 * SurfaceActivation::RATE() +
                5 * SurfaceDeactivation::RATE() +
                2 * TwoBridgesToHighBridge::RATE() +
                2 * AdsMethylTo111::RATE() +
                DimerFormationNearBridge::RATE());
    assert_atom(0, 1, 0, 1, 0);
    assert_atom(0, 2, 0, 1, 0);
    assert_atom(0, 2, 1, 2, 1);

    // 26
    Handbook::mc().doOneOfOne(DIMER_FORMATION_NEAR_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 2, 1);
    assert_rate(2 * SurfaceActivation::RATE() +
                4 * SurfaceDeactivation::RATE() +
                TwoBridgesToHighBridge::RATE() +
                AdsMethylTo111::RATE() +
                AdsMethylToDimer::RATE() +
                DimerDropNearBridge::RATE());
    assert_atom(0, 1, 1, 4, 0);
    assert_atom(0, 2, 1, 3, 1);

    // 27
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    assert_rate(2 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                3 * MethylOnDimerActivation::RATE() +
                TwoBridgesToHighBridge::RATE() +
                AdsMethylTo111::RATE() +
                DesMethylFromDimer::RATE());
    assert_atom(0, 2, 1, 4, 0);
    assert_amorph_atom(0, 2, 1, 1, 0);

    // 28
    buildBridge(s.x-1, 1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-1, 1, 1);
    buildBridge(s.x-1, 2, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-1, 2, 1);
    assert_rate(4 * SurfaceActivation::RATE() +
                5 * SurfaceDeactivation::RATE() +
                3 * MethylOnDimerActivation::RATE() +
                TwoBridgesToHighBridge::RATE() +
                AdsMethylTo111::RATE() +
                DesMethylFromDimer::RATE() +
                DimerFormationAtEnd::RATE());
    assert_atom(s.x-1, 1, 0, 1, 0);
    assert_atom(0, 1, 0, 2, 0);
    assert_atom(s.x-1, 1, 1, 2, 1);
    assert_atom(s.x-1, 2, 0, 1, 0);
    assert_atom(0, 2, 0, 2, 0);
    assert_atom(s.x-1, 2, 1, 2, 1);

    // 29
    Handbook::mc().doOneOfOne(DIMER_FORMATION_AT_END);
    buildBridge(s.x-2, 1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, 1, 1);
    buildBridge(s.x-2, 2, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, 2, 1);
    assert_rate(6 * SurfaceActivation::RATE() +
                5 * SurfaceDeactivation::RATE() +
                3 * MethylOnDimerActivation::RATE() +
                TwoBridgesToHighBridge::RATE() +
                AdsMethylTo111::RATE() +
                DesMethylFromDimer::RATE() +
                DimerFormationAtEnd::RATE() +
                DimerDropAtEnd::RATE());
    assert_atom(s.x-1, 1, 1, 3, 0);
    assert_atom(s.x-1, 2, 1, 3, 0);
    assert_atom(s.x-2, 1, 0, 1, 0);
    assert_atom(s.x-1, 1, 0, 2, 0);
    assert_atom(s.x-2, 1, 1, 2, 1);
    assert_atom(s.x-2, 2, 0, 1, 0);
    assert_atom(s.x-1, 2, 0, 2, 0);
    assert_atom(s.x-2, 2, 1, 2, 1);

    // 30
    Handbook::mc().doOneOfOne(DIMER_FORMATION_AT_END);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-1, 2, 1);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    assert_rate(5 * SurfaceActivation::RATE() +
                4 * SurfaceDeactivation::RATE() +
                2 * MethylOnDimerActivation::RATE() +
                MethylOnDimerDeactivation::RATE() +
                TwoBridgesToHighBridge::RATE() +
                AdsMethylTo111::RATE() +
                DesMethylFromDimer::RATE() +
                DimerDropInMiddle::RATE() +
                DimerDropAtEnd::RATE() +
                MethylToHighBridge::RATE() +
                MigrationThroughDimersRow::RATE() +
                AdsMethylToDimer::RATE());
    assert_atom(s.x-2, 1, 1, 3, 0);
    assert_atom(s.x-2, 2, 1, 3, 0);
    assert_atom(s.x-1, 2, 1, 3, 1);
    assert_atom(0, 2, 1, 4, 0);
    assert_amorph_atom(0, 2, 1, 1, 1);

    // 31
    Handbook::mc().doOneOfOne(MIGRATION_THROUGH_DIMERS_ROW);
    assert_rate(7 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                2 * SierpinskiDrop::RATE() +
                TwoBridgesToHighBridge::RATE() +
                AdsMethylTo111::RATE() +
                DimerDropAtEnd::RATE());
    assert_atom(s.x-1, 2, 1, 4, 0);
    assert_atom(0, 2, 1, 4, 0);
    assert_amorph_atom(0, 2, 1, 2, 0);
    assert_amorph_atom(s.x-1, 2, 1, 2, 0); // same as prev

    // 32
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-1, 1, 1);
    assert_rate(6 * SurfaceActivation::RATE() +
                4 * SurfaceDeactivation::RATE() +
                2 * SierpinskiDrop::RATE() +
                AdsMethylToDimer::RATE() +
                AdsMethylTo111::RATE() +
                TwoBridgesToHighBridge::RATE() +
                DimerDropAtEnd::RATE());
    assert_atom(s.x-1, 1, 1, 3, 1);

    // 33
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    assert_rate(6 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                3 * MethylOnDimerActivation::RATE() +
                2 * SierpinskiDrop::RATE() +
                DesMethylFromDimer::RATE() +
                AdsMethylTo111::RATE() +
                TwoBridgesToHighBridge::RATE() +
                DimerDropAtEnd::RATE());
    assert_atom(s.x-1, 1, 1, 4, 0);
    assert_amorph_atom(s.x-1, 1, 1, 1, 0);

    // 34
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    assert_rate(8 * SurfaceActivation::RATE() +
                4 * SurfaceDeactivation::RATE() +
                2 * SierpinskiDrop::RATE() +
                AdsMethylTo111::RATE() +
                TwoBridgesToHighBridge::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-1, 2, 1, 3, 1);
    assert_atom(s.x-1, 1, 1, 4, 0);
    assert_amorph_atom(s.x-1, 1, 1, 2, 0);

    // 35
    Handbook::mc().doLastOfOne(SIERPINSKI_DROP);
    assert_rate(8 * SurfaceActivation::RATE() +
                6 * SurfaceDeactivation::RATE() +
                FormTwoBond::RATE() +
                DesMethylFromBridge::RATE() +
                AdsMethylToDimer::RATE() +
                AdsMethylTo111::RATE() +
                TwoBridgesToHighBridge::RATE() +
                DimerDropNearBridge::RATE() +
                DimerDrop::RATE());
    assert_atom(0, 2, 1, 3, 1);
    assert_atom(s.x-1, 2, 1, 3, 1);
    assert_amorph_atom(s.x-1, 2, 1, 1, 1);

    // 36
    Handbook::mc().doOneOfOne(DES_METHYL_FROM_BRIDGE);
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_TO_METHYL);
    Handbook::mc().doOneOfOne(DES_METHYL_FROM_DIMER);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-1, 1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-1, 2, 1);
    assert_rate(6 * SurfaceActivation::RATE() +
                4 * SurfaceDeactivation::RATE() +
                AdsMethylToDimer::RATE() +
                AdsMethylTo111::RATE() +
                TwoBridgesToHighBridge::RATE() +
                DimerDropNearBridge::RATE() +
                DimerDropInMiddle::RATE() +
                DimerDropAtEnd::RATE());
    assert_atom(s.x-1, 2, 1, 3, 0);
    assert_atom(s.x-1, 1, 1, 3, 0);

    // 37
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    Handbook::mc().doOneOfOne(DIMER_DROP_IN_MIDDLE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-1, 2, 1);
    assert_rate(5 * SurfaceActivation::RATE() +
                6 * SurfaceDeactivation::RATE() +
                2 * MethylOnDimerActivation::RATE() +
                MethylOnDimerDeactivation::RATE() +
                TwoBridgesToHighBridge::RATE() +
                AdsMethylTo111::RATE() +
                DesMethylFromDimer::RATE() +
                DimerFormationInMiddle::RATE() +
                DimerDrop::RATE() +
                MethylToHighBridge::RATE());
    assert_atom(s.x-1, 1, 1, 2, 1);
    assert_atom(s.x-1, 2, 1, 2, 2);
    assert_atom(0, 2, 1, 4, 0);
    assert_amorph_atom(0, 2, 1, 1, 1);

    // 38
    Handbook::mc().doOneOfOne(DIMER_FORMATION_IN_MIDDLE);
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    assert_rate(7 * SurfaceActivation::RATE() +
                5 * SurfaceDeactivation::RATE() +
                2 * TwoBridgesToHighBridge::RATE() +
                2 * AdsMethylTo111::RATE() +
                2 * DimerDropAtEnd::RATE() +
                HighBridgeToTwoBridges::RATE() +
                HighBridgeToMethyl::RATE() +
                AdsMethylToDimer::RATE());
    assert_atom(s.x-1, 1, 1, 3, 0);
    assert_atom(s.x-1, 2, 1, 3, 1);
    assert_atom(0, 2, 1, 4, 0);
    assert_amorph_atom(0, 2, 1, 2, 0);

    // 39
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    assert_rate(7 * SurfaceActivation::RATE() +
                4 * SurfaceDeactivation::RATE() +
                3 * MethylOnDimerActivation::RATE() +
                2 * TwoBridgesToHighBridge::RATE() +
                2 * AdsMethylTo111::RATE() +
                DesMethylFromDimer::RATE() +
                DimerDropAtEnd::RATE() +
                HighBridgeToTwoBridges::RATE() +
                HighBridgeToMethyl::RATE());
    assert_atom(s.x-1, 2, 1, 4, 0);
    assert_amorph_atom(s.x-1, 2, 1, 1, 0);

    // 40
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_TWO_BRIDGES);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, 2, 1);
    assert_rate(10 * SurfaceActivation::RATE() +
                4 * SurfaceDeactivation::RATE() +
                TwoBridgesToHighBridge::RATE() +
                AdsMethylTo111::RATE() +
                DimerDrop::RATE() +
                HighBridgeStandToOneBridge::RATE() +
                HighBridgeToMethyl::RATE());
    assert_atom(0, 2, 1, 3, 0);
    assert_atom(0, 1, 1, 4, 0);
    assert_atom(0, 1, 2, 2, 0);
    assert_atom(s.x-1, 1, 1, 2, 1);
    assert_atom(s.x-1, 2, 1, 4, 0);
    assert_amorph_atom(s.x-1, 2, 1, 2, 0);

    // 41
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_ONE_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 1, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-1, 1, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-1, 2, 1);
    assert_rate(9 * SurfaceActivation::RATE() +
                5 * SurfaceDeactivation::RATE() +
                TwoBridgesToHighBridge::RATE() +
                AdsMethylTo111::RATE() +
                DimerDrop::RATE() +
                DimerFormation::RATE());
    assert_atom(s.x-1, 2, 1, 3, 0);
    assert_atom(s.x-1, 1, 1, 3, 0);
    assert_atom(s.x-1, 1, 2, 2, 1);
    assert_atom(0, 1, 2, 2, 1);

    // 42
    Handbook::mc().doOneOfOne(DIMER_FORMATION);
    assert_rate(9 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                2 * DimerDrop::RATE() +
                TwoBridgesToHighBridge::RATE() +
                AdsMethylTo111::RATE());
    assert_atom(s.x-1, 1, 2, 3, 0);
    assert_atom(0, 1, 2, 3, 0);

    // 43
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, s.y-1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, s.y-1, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, 0, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-1, 1, 2);
    assert_rate(11 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                2 * DimerDrop::RATE() +
                AdsMethylToDimer::RATE());
    assert_atom(0, s.y-1, 1, 3, 0);
    assert_atom(0, s.y-1, 2, 2, 0);
    assert_atom(0, 0, 2, 2, 0);
    assert_atom(s.x-1, 1, 2, 3, 1);

    // 44
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, 2, 1);
    assert_rate(10 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                2 * MethylOnDimerActivation::RATE() +
                MethylOnDimerDeactivation::RATE() +
                MethylToHighBridge::RATE() +
                DesMethylFromDimer::RATE() +
                DimerDrop::RATE() +
                MigrationDownAtDimerFromDimer::RATE() +
                AdsMethylToDimer::RATE());
    assert_atom(s.x-2, 2, 1, 3, 1);
    assert_atom(s.x-1, 1, 2, 4, 0);
    assert_amorph_atom(s.x-1, 1, 2, 1, 1);

    // 45
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    assert_rate(12 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                HighBridgeToMethyl::RATE() +
                HighBridgeStandToOneBridge::RATE() +
                MigrationDownAtDimerFromHighBridge::RATE() +
                DimerDrop::RATE() +
                AdsMethylToDimer::RATE());
    assert_atom(s.x-1, 1, 2, 4, 0);
    assert_amorph_atom(s.x-1, 1, 2, 2, 0);

    // 46
    Handbook::mc().doOneOfOne(MIGRATION_DOWN_AT_DIMER_FROM_HIGH_BRIDGE);
    assert_rate(12 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                DimerDrop::RATE() +
                AdsMethylToDimer::RATE());
    assert_atom(s.x-1, 1, 2, 3, 1);
    assert_atom(s.x-2, 1, 2, 3, 0);
    assert_atom(s.x-2, 1, 1, 3, 0);
    assert_atom(s.x-2, 2, 1, 3, 0);

    // 47
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, 1, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-1, 1, 2);
    buildBridge(s.x-1, 0, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-1, 0, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-1, 1, 1);
    assert_rate(14 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                DimerFormationNearBridge::RATE() +
                DimerDrop::RATE() +
                AdsMethylTo111::RATE());
    assert_atom(0, 1, 2, 2, 0);
    assert_atom(s.x-1, 1, 2, 3, 0);
    assert_atom(s.x-1, 1, 1, 3, 1);
    assert_atom(s.x-1, 0, 1, 2, 1);
    assert_atom(s.x-1, 0, 0, 1, 0);
    assert_atom(0, 0, 0, 2, 0);

    // 48
    Handbook::mc().doOneOfOne(DIMER_FORMATION_NEAR_BRIDGE);
    assert_rate(14 * SurfaceActivation::RATE() +
                DimerDropNearBridge::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-1, 1, 1, 4, 0);
    assert_atom(s.x-1, 0, 1, 3, 0);

    // 49
    Handbook::mc().doOneOfOne(DIMER_DROP_NEAR_BRIDGE);
    Handbook::mc().doOneOfOne(DIMER_DROP);
    assert_rate(14 * SurfaceActivation::RATE() +
                4 * SurfaceDeactivation::RATE() +
                DimerFormationNearBridge::RATE() +
                DimerFormation::RATE() +
                AdsMethylTo111::RATE() +
                NextLevelBridgeToHighBridge::RATE());
    assert_atom(s.x-1, 1, 1, 3, 1);
    assert_atom(s.x-1, 0, 1, 2, 1);
    assert_atom(s.x-1, 1, 2, 2, 1);
    assert_atom(s.x-2, 1, 2, 2, 1);

    // 50
    Handbook::mc().doOneOfOne(DIMER_FORMATION_NEAR_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-1, 2, 1);
    assert_rate(13 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                BridgeWithDimerToHighBridgeAndDimer::RATE() +
                AdsMethylTo111::RATE() +
                DimerDropNearBridge::RATE() +
                DimerFormation::RATE());
    assert_atom(s.x-1, 2, 1, 3, 1);
    assert_atom(s.x-1, 1, 1, 4, 0);
    assert_atom(s.x-1, 0, 1, 3, 0);

    // 51
    Handbook::mc().doOneOfOne(BRIDGE_WITH_DIMER_TO_HIGH_BRIDGE_AND_DIMER);
    assert_rate(13 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                HighBridgeStandToDimer::RATE() +
                AdsMethylToDimer::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-1, 1, 1, 3, 1);
    assert_atom(s.x-1, 2, 1, 4, 0);
    assert_amorph_atom(s.x-1, 2, 1, 2, 1);

    // 52
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_DIMER);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-1, 2, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-1, 0, 1);
    assert_rate(13 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                AdsMethylToDimer::RATE() +
                DimerDropNearBridge::RATE() +
                DimerFormation::RATE());
    assert_atom(s.x-1, 0, 1, 3, 1);
    assert_atom(s.x-1, 1, 1, 4, 0);
    assert_atom(s.x-1, 2, 1, 3, 0);
    assert_atom(s.x-1, 1, 2, 2, 1);

    // 53
    Handbook::mc().doOneOfOne(DIMER_FORMATION);
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    assert_rate(13 * SurfaceActivation::RATE() +
                2 * MethylOnDimerActivation::RATE() +
                MethylOnDimerDeactivation::RATE() +
                DesMethylFromDimer::RATE() +
                MethylToHighBridge::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-2, 1, 2, 3, 0);
    assert_atom(s.x-1, 1, 2, 3, 0);
    assert_atom(s.x-1, 0, 1, 4, 0);
    assert_amorph_atom(s.x-1, 0, 1, 1, 1);

    // 54
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    assert_rate(15 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                HighBridgeToMethyl::RATE() +
                HighBridgeToTwoBridges::RATE() +
                AdsMethylTo111::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-1, 1, 1, 3, 1);
    assert_atom(s.x-1, 0, 1, 4, 0);
    assert_amorph_atom(s.x-1, 0, 1, 2, 0);

    // 55
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_TWO_BRIDGES);
    assert_rate(15 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                TwoBridgesToHighBridge::RATE() +
                AdsMethylTo111::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-1, 1, 1, 4, 0);
    assert_atom(s.x-1, 0, 1, 3, 1);
    assert_atom(s.x-1, 0, 2, 2, 0);

    // 56
    Handbook::mc().doOneOfOne(TWO_BRIDGES_TO_HIGH_BRIDGE);
    buildBridge(s.x-1, s.y-1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-1, s.y-1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-1, 1, 1);
    assert_rate(17 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                HighBridgeToMethyl::RATE() +
                HighBridgeStandToOneBridge::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-1, 1, 1, 3, 0);
    assert_atom(s.x-1, 0, 1, 4, 0);
    assert_atom(s.x-1, s.y-1, 1, 2, 1);
    assert_atom(s.x-1, s.y-1, 0, 1, 0);
    assert_atom(0, s.y-1, 0, 2, 0);

    // 57
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_TO_METHYL);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-1, s.y-1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-1, 1, 1);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    assert_rate(13 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                3 * MethylOnDimerDeactivation::RATE() +
                MethylToHighBridge::RATE() +
                DesMethylFromDimer::RATE() +
                AdsMethylToDimer::RATE() +
                AdsMethylTo111::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-1, 1, 1, 3, 1);
    assert_atom(s.x-1, 0, 1, 4, 0);
    assert_amorph_atom(s.x-1, 0, 1, 1, 3);
    assert_atom(s.x-1, s.y-1, 1, 3, 1);

    // 58
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    assert_rate(13 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                2 * MethylOnDimerActivation::RATE() +
                4 * MethylOnDimerDeactivation::RATE() +
                2 * MethylToHighBridge::RATE() +
                2 * DesMethylFromDimer::RATE() +
                AdsMethylTo111::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-1, s.y-1, 1, 4, 0);
    assert_amorph_atom(s.x-1, s.y-1, 1, 1, 1);

    // 59
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    assert_rate(15 * SurfaceActivation::RATE() +
                5 * SurfaceDeactivation::RATE() +
                HighBridgeToTwoBridges::RATE() +
                HighBridgeToMethyl::RATE() +
                DesMethylFromBridge::RATE() +
                FormTwoBond::RATE() +
                AdsMethylTo111::RATE() +
                DimerDrop::RATE());
    assert_amorph_atom(s.x-1, 0, 1, 2, 2);
    assert_atom(s.x-1, 0, 1, 4, 0);
    assert_atom(s.x-1, s.y-1, 1, 3, 1);

    // 60
    Handbook::mc().doOneOfOne(FORM_TWO_BOND);
    assert_rate(15 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                HighBridgeToTwoBridges::RATE() +
                HighBridgeToMethyl::RATE() +
                AdsMethylTo111::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-1, s.y-1, 1, 4, 0);
    assert_amorph_atom(s.x-1, s.y-1, 1, 2, 0);

    // 61
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_TWO_BRIDGES);
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_TWO_BRIDGES);
    assert_rate(15 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                TwoBridgesToHighBridge::RATE() +
                AdsMethylTo111::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-1, s.y-1, 2, 2, 0);
    assert_atom(s.x-1, 0, 2, 2, 2);
    assert_atom(s.x-1, 1, 1, 4, 0);
    assert_atom(s.x-1, 0, 1, 4, 0);
    assert_atom(s.x-1, s.y-1, 1, 3, 1);

    // 62
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_111);
    assert_rate(18 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                DesMethylFrom111::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-1, s.y-1, 1, 4, 0);
    assert_amorph_atom(s.x-1, s.y-1, 1, 1, 0);

    // 63
    Handbook::mc().doOneOfOne(DES_METHYL_FROM_111);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, s.y-1, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-1, s.y-1, 2);
    assert_rate(13 * SurfaceActivation::RATE() +
                5 * SurfaceDeactivation::RATE() +
                AdsMethylTo111::RATE() +
                TwoBridgesToHighBridge::RATE() +
                DimerFormation::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-1, s.y-1, 1, 3, 1);
    assert_atom(s.x-1, s.y-1, 2, 2, 1);
    assert_atom(0, s.y-1, 2, 2, 1);

    // 64
    Handbook::mc().doOneOfOne(DIMER_FORMATION);
    assert_rate(13 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                2 * DimerDrop::RATE() +
                AdsMethylTo111::RATE());
    assert_atom(s.x-1, s.y-1, 2, 3, 0);
    assert_atom(0, s.y-1, 2, 3, 0);

    // 65
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-1, s.y-1, 1);
    buildBridge(s.x-2, s.y-1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, s.y-1, 1);
    buildBridge(s.x-2, 0, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, 0, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, s.y-1, 2);
    assert_rate(15 * SurfaceActivation::RATE() +
                5 * SurfaceDeactivation::RATE() +
                2 * DimerDrop::RATE() +
                DimerFormation::RATE() +
                AdsMethylToDimer::RATE());
    assert_atom(0, s.y-1, 2, 3, 1);
    assert_atom(s.x-1, s.y-1, 1, 3, 0);
    assert_atom(s.x-2, s.y-1, 1, 2, 1);
    assert_atom(s.x-2, s.y-1, 0, 1, 0);
    assert_atom(s.x-1, s.y-1, 0, 2, 0);
    assert_atom(s.x-2, 0, 1, 2, 1);
    assert_atom(s.x-2, 0, 0, 1, 0);
    assert_atom(s.x-1, 0, 0, 2, 0);

    // 66
    Handbook::mc().doOneOfOne(DIMER_FORMATION);
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-1, s.y-1, 2);
    assert_rate(14 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                2 * MethylOnDimerActivation::RATE() +
                MethylOnDimerDeactivation::RATE() +
                2 * DimerDrop::RATE() +
                DesMethylFromDimer::RATE() +
                MethylOnDimerHydrogenMigration::RATE() +
                MethylToHighBridge::RATE() +
                AdsMethylToDimer::RATE());
    assert_atom(s.x-2, s.y-1, 1, 3, 0);
    assert_atom(s.x-2, 0, 1, 3, 0);
    assert_atom(s.x-1, s.y-1, 2, 3, 1);
    assert_atom(0, s.y-1, 2, 4, 0);
    assert_amorph_atom(0, s.y-1, 2, 1, 1);

    // 67
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, s.y-1, 1);
    assert_rate(15 * SurfaceActivation::RATE() +
                5 * SurfaceDeactivation::RATE() +
                2 * DimerDrop::RATE() +
                HighBridgeToMethyl::RATE() +
                HighBridgeStandToOneBridge::RATE() +
                AdsMethylToDimer::RATE());
    assert_atom(s.x-2, s.y-1, 1, 3, 1);
    assert_atom(s.x-1, s.y-1, 2, 2, 2);
    assert_atom(0, s.y-1, 2, 4, 0);
    assert_amorph_atom(0, s.y-1, 2, 2, 0);

    // 68
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_ONE_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, s.y-1, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 0, 2);
    assert_rate(15 * SurfaceActivation::RATE() +
                5 * SurfaceDeactivation::RATE() +
                2 * DimerDrop::RATE() +
                DimerFormation::RATE() +
                NextLevelBridgeToHighBridge::RATE() +
                AdsMethylTo111::RATE() +
                AdsMethylToDimer::RATE());
    assert_atom(s.x-1, s.y-1, 3, 2, 0);
    assert_atom(s.x-1, s.y-1, 2, 3, 1);
    assert_atom(0, s.y-1, 2, 3, 0);
    assert_atom(0, 0, 2, 2, 1);

    // 69
    Handbook::mc().doOneOfOne(DIMER_FORMATION);
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_111);
    Handbook::mc().doLastOfMul(CORR_SURFACE_ACTIVATION);
    assert_rate(17 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                3 * DimerDrop::RATE() +
                2 * AdsMethylToDimer::RATE() +
                DesMethylFrom111::RATE() +
                MigrationDownAtDimerFrom111::RATE());
    assert_atom(0, 0, 2, 3, 0);
    assert_atom(s.x-1, 0, 2, 3, 1);
    assert_atom(s.x-1, s.y-1, 2, 4, 0);
    assert_amorph_atom(s.x-1, s.y-1, 2, 1, 1);

    // 70
    Handbook::mc().doOneOfOne(MIGRATION_DOWN_AT_DIMER_FROM_111);
    assert_rate(17 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                2 * DimerDrop::RATE() +
                DimerDropNearBridge::RATE() +
                AbsHydrogenFromGap::RATE() +
                AdsMethylToDimer::RATE());
    assert_atom(s.x-1, s.y-1, 2, 4, 0);
    assert_atom(s.x-2, s.y-1, 2, 3, 0);
    assert_atom(s.x-2, s.y-1, 1, 3, 0);
    assert_atom(s.x-2, 0, 1, 3, 0);

    // 71
    Handbook::mc().doOneOfOne(ABS_HYDROGEN_FROM_GAP);
    // checks that correctly finds in both directions
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, 0, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, 1, 1);
    Handbook::mc().doOneOfOne(ABS_HYDROGEN_FROM_GAP);
    // end of both directions find checking
    assert_rate(15 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                2 * AdsMethylTo111::RATE() +
                2 * DimerDrop::RATE() +
                DimerDropNearBridge::RATE() +
                AdsMethylToDimer::RATE());
    assert_atom(s.x-2, 0, 1, 3, 1);
    assert_atom(s.x-2, 1, 1, 3, 1);

    // 72
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    assert_rate(15 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                2 * MethylOnDimerActivation::RATE() +
                MethylOnDimerDeactivation::RATE() +
                2 * AdsMethylTo111::RATE() +
                DesMethylFromDimer::RATE() +
                MethylToHighBridge::RATE() +
                DimerDrop::RATE() +
                DimerDropNearBridge::RATE());
    assert_atom(s.x-1, 0, 2, 4, 0);
    assert_amorph_atom(s.x-1, 0, 2, 1, 1);

    // 73
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    assert_rate(17 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                2 * AdsMethylTo111::RATE() +
                HighBridgeToMethyl::RATE() +
                HighBridgeStandToOneBridge::RATE() +
                DimerDrop::RATE() +
                DimerDropNearBridge::RATE());
    assert_atom(0, 0, 2, 2, 1);
    assert_atom(s.x-1, 0, 2, 4, 0);
    assert_amorph_atom(s.x-1, 0, 2, 2, 0);

    // 74
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_ONE_BRIDGE);
    Handbook::mc().doOneOfOne(DIMER_DROP);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-1, 1, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, 1, 2);
    assert_rate(19 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                3 * AdsMethylTo111::RATE() +
                2 * NextLevelBridgeToHighBridge::RATE() +
                DimerDropNearBridge::RATE());
    assert_atom(0, 0, 2, 3, 0);
    assert_atom(s.x-1, 0, 2, 3, 1);
    assert_atom(s.x-1, 0, 3, 2, 0);
    assert_atom(s.x-1, 1, 2, 2, 0);
    assert_atom(s.x-2, 1, 2, 2, 0);

    // 75
    Handbook::mc().doOneOfOne(DIMER_DROP_NEAR_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-1, s.y-1, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, s.y-1, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-1, s.y-1, 3);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-1, 0, 3);
    assert_rate(19 * SurfaceActivation::RATE() +
                5 * SurfaceDeactivation::RATE() +
                3 * AdsMethylTo111::RATE() +
                3 * NextLevelBridgeToHighBridge::RATE() +
                DimerFormation::RATE());
    assert_atom(s.x-2, s.y-1, 2, 2, 0);
    assert_atom(s.x-1, s.y-1, 2, 3, 0);
    assert_atom(s.x-1, s.y-1, 3, 2, 1);
    assert_atom(s.x-1, 0, 3, 2, 1);

    // 76
    Handbook::mc().doOneOfOne(DIMER_FORMATION);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, s.y-1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, 2, 1);
    assert_rate(17 * SurfaceActivation::RATE() +
                5 * SurfaceDeactivation::RATE() +
                5 * AdsMethylTo111::RATE() +
                4 * NextLevelBridgeToHighBridge::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-1, s.y-1, 3, 3, 0);
    assert_atom(s.x-1, 0, 3, 3, 0);
    assert_atom(s.x-2, s.y-1, 1, 3, 1);
    assert_atom(s.x-2, 2, 1, 3, 1);

    // 77
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, 0, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, 1, 1);
    Handbook::mc().doOneOfOne(NEXT_LEVEL_BRIDGE_TO_HIGH_BRIDGE);
    Handbook::mc().doOneOfOne(NEXT_LEVEL_BRIDGE_TO_HIGH_BRIDGE);
    Handbook::mc().doOneOfOne(DIMER_FORMATION);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, 0, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, 1, 1);
    assert_rate(17 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                2 * HighBridgeStandToDimer::RATE() +
                2 * DimerDrop::RATE() +
                2 * AdsMethylToDimer::RATE() +
                AdsMethylTo111::RATE());
    assert_atom(s.x-2, s.y-1, 1, 4, 0);
    assert_atom(s.x-2, 0, 1, 3, 1);
    assert_atom(s.x-2, 1, 1, 3, 1);
    assert_atom(s.x-2, 2, 1, 4, 0);

    // 78
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, 1, 1);
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_DIMER);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, 1, 1);
    assert_rate(17 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                2 * AdsMethylTo111::RATE() +
                AdsMethylToDimer::RATE() +
                BridgeWithDimerToHighBridgeAndDimer::RATE() +
                DimerDropNearBridge::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-2, s.y-1, 1, 3, 1);
    assert_atom(s.x-2, 0, 1, 4, 0);
    assert_atom(s.x-2, 1, 1, 3, 1);

    // 79
    Handbook::mc().doOneOfOne(DIMER_DROP_NEAR_BRIDGE);
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_ONE_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, s.y-1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, 2, 1);
    assert_rate(19 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                3 * AdsMethylTo111::RATE() +
                2 * NextLevelBridgeToHighBridge::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-2, s.y-1, 1, 3, 0);
    assert_atom(s.x-2, 0, 1, 3, 1);
    assert_atom(s.x-2, 1, 1, 3, 1);
    assert_atom(s.x-2, 2, 1, 3, 0);

    // 80
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, 0, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, 1, 1);
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_111);
    Handbook::mc().doLastOfMul(CORR_SURFACE_ACTIVATION);
    Handbook::mc().doLastOfMul(CORR_SURFACE_ACTIVATION);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, 0, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, 1, 1);
    assert_rate(20 * SurfaceActivation::RATE() +
                4 * SurfaceDeactivation::RATE() +
                2 * AdsMethylTo111::RATE() +
                2 * NextLevelBridgeToHighBridge::RATE() +
                DesMethylFrom111::RATE() +
                MigrationDownInGapFrom111::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-2, 0, 1, 3, 1);
    assert_atom(s.x-2, 1, 1, 3, 1);
    assert_atom(s.x-1, 0, 2, 4, 0);
    assert_amorph_atom(s.x-1, 0, 2, 1, 2);

    // 81
    Handbook::mc().doOneOfOne(MIGRATION_DOWN_IN_GAP_FROM_111);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, s.y-1, 1);
    assert_rate(19 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                TwoBridgesToHighBridge::RATE() +
                AdsMethylTo111::RATE() +
                DimerDropNearBridge::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-2, 1, 1, 4, 0);
    assert_atom(s.x-2, 0, 1, 4, 0);
    assert_atom(s.x-2, 0, 2, 3, 0);
    assert_atom(s.x-1, 0, 2, 4, 0);
    assert_atom(s.x-2, s.y-1, 1, 3, 1);

    // 82
    Handbook::mc().doOneOfOne(TWO_BRIDGES_TO_HIGH_BRIDGE);
    assert_rate(19 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                HighBridgeToTwoBridges::RATE() +
                HighBridgeToMethyl::RATE() +
                AdsMethylTo111::RATE() +
                DimerDropNearBridge::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-2, 0, 1, 3, 1);
    assert_atom(s.x-2, s.y-1, 1, 4, 0);
    assert_amorph_atom(s.x-2, s.y-1, 1, 2, 0);

    // 83
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_TO_METHYL);
    Handbook::mc().doOneOfOne(DIMER_DROP_NEAR_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-1, 0, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, 0, 2);
    assert_rate(19 * SurfaceActivation::RATE() +
                2 * MethylOnDimerActivation::RATE() +
                MethylOnDimerDeactivation::RATE() +
                DesMethylFromDimer::RATE() +
                MethylToHighBridge::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-1, 0, 2, 3, 0);
    assert_atom(s.x-2, 0, 2, 2, 0);
    assert_atom(s.x-2, 0, 1, 4, 0);
    assert_atom(s.x-2, s.y-1, 1, 4, 0);
    assert_amorph_atom(s.x-2, s.y-1, 1, 1, 1);

    // 84
    Handbook::mc().doOneOfOne(DES_METHYL_FROM_DIMER);
    assert_rate(19 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                AdsMethylToDimer::RATE() +
                DimerDropNearBridge::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-2, s.y-1, 1, 3, 1);

    // 85
    Handbook::mc().doOneOfOne(DIMER_DROP_NEAR_BRIDGE);
    assert_rate(19 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                AdsMethylTo111::RATE() +
                TwoBridgesToHighBridge::RATE() +
                DimerFormationNearBridge::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-2, s.y-1, 1, 2, 2);
    assert_atom(s.x-2, 0, 1, 3, 1);

    // 86
    Handbook::mc().doOneOfOne(TWO_BRIDGES_TO_HIGH_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, s.y-1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, 1, 1);
    assert_rate(21 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                HighBridgeStandToOneBridge::RATE() +
                HighBridgeToMethyl::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-2, s.y-1, 1, 2, 1);
    assert_atom(s.x-2, 1, 1, 3, 0);
    assert_atom(s.x-2, 0, 1, 4, 0);
    assert_amorph_atom(s.x-2, 0, 1, 2, 0);

    // 87
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_ONE_BRIDGE);
    Handbook::mc().doOneOfOne(DIMER_DROP);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-1, s.y-1, 3);
    assert_rate(22 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                AdsMethylTo111::RATE() +
                NextLevelBridgeToHighBridge::RATE());
    assert_atom(s.x-1, 0, 3, 2, 1);
    assert_atom(s.x-1, s.y-1, 3, 2, 0);
    assert_atom(s.x-2, s.y-1, 2, 2, 0);
    assert_atom(s.x-2, s.y-1, 1, 3, 0);
    assert_atom(s.x-2, 0, 1, 3, 1);

    // 88
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, 1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-1, 0, 2);
    assert_rate(20 * SurfaceActivation::RATE() +
                4 * SurfaceDeactivation::RATE() +
                3 * AdsMethylTo111::RATE() +
                3 * NextLevelBridgeToHighBridge::RATE());
    assert_atom(s.x-2, 1, 1, 3, 1);
    assert_atom(s.x-1, 0, 2, 3, 1);

    // 89
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, 0, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, 1, 1);
    Handbook::mc().doOneOfOne(NEXT_LEVEL_BRIDGE_TO_HIGH_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, 0, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, 0, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, 1, 1);
    assert_rate(21 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                2 * AdsMethylTo111::RATE() +
                2 * NextLevelBridgeToHighBridge::RATE() +
                MigrationDownInGapFromHighBridge::RATE());
    assert_atom(s.x-2, 1, 1, 3, 1);
    assert_atom(s.x-2, 0, 1, 3, 1);
    assert_atom(s.x-1, 0, 2, 4, 0);
    assert_amorph_atom(s.x-1, 0, 2, 2, 1);
    assert_atom(0, 0, 2, 2, 0);

    // 90
    Handbook::mc().doOneOfOne(MIGRATION_DOWN_IN_GAP_FROM_HIGH_BRIDGE);
    assert_rate(21 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                AdsMethylToDimer::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-2, 1, 1, 4, 0);
    assert_atom(s.x-2, 0, 1, 4, 0);
    assert_atom(s.x-2, 0, 2, 3, 0);
    assert_atom(s.x-1, 0, 2, 3, 1);

    // 91
    Handbook::mc().doOneOfOne(DIMER_DROP);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, 0, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-1, 0, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 0, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, s.y-1, 1);
    Handbook::mc().doOneOfOne(TWO_BRIDGES_TO_HIGH_BRIDGE);
    assert_rate(21 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                DimerFormation::RATE() +
                TwoBridgesToHighBridge::RATE() +
                HighBridgeToTwoBridges::RATE() +
                HighBridgeToMethyl::RATE() +
                AdsMethylTo111::RATE());
    assert_amorph_atom(s.x-2, s.y-1, 1, 2, 0);
    assert_atom(s.x-2, s.y-1, 1, 4, 0);
    assert_atom(s.x-2, 0, 1, 3, 1);
    assert_atom(s.x-2, 0, 2, 2, 0);
    assert_atom(s.x-1, 0, 2, 2, 1);
    assert_atom(0, 0, 2, 2, 1);

    // 92
    Handbook::mc().doOneOfOne(DIMER_FORMATION);
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_TO_METHYL);
    Handbook::mc().doOneOfOne(DES_METHYL_FROM_DIMER);
    assert_rate(19 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                DimerDrop::RATE() +
                DimerDropNearBridge::RATE() +
                AdsMethylToDimer::RATE());
    assert_atom(s.x-1, 0, 2, 3, 0);
    assert_atom(0, 0, 2, 3, 0);
    assert_atom(s.x-2, 0, 1, 4, 0);
    assert_atom(s.x-2, s.y-1, 1, 3, 1);

    // 93
    Handbook::mc().doOneOfOne(DIMER_DROP_NEAR_BRIDGE);
    Handbook::mc().doOneOfOne(TWO_BRIDGES_TO_HIGH_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, s.y-1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-1, 0, 2);
    assert_rate(19 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                2 * HighBridgeToMethyl::RATE() +
                DimerDrop::RATE() +
                NextLevelBridgeToHighBridge::RATE() +
                HighBridgeStandToOneBridge::RATE() +
                HighBridgeToTwoBridges::RATE() +
                AdsMethylTo111::RATE() +
                AdsMethylToDimer::RATE());
    assert_atom(s.x-1, 0, 2, 3, 1);
    assert_atom(s.x-2, 1, 1, 3, 1);
    assert_amorph_atom(s.x-2, 0, 1, 2, 0);
    assert_atom(s.x-2, 0, 1, 4, 0);
    assert_atom(s.x-2, s.y-1, 1, 2, 1);

    // 94
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_ONE_BRIDGE);
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    assert_rate(19 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                MethylOnDimerActivation::RATE() +
                2 * MethylOnDimerDeactivation::RATE() +
                2 * NextLevelBridgeToHighBridge::RATE() +
                2 * AdsMethylTo111::RATE() +
                MigrationDownInGapFromDimer::RATE() +
                MethylToHighBridge::RATE() +
                DesMethylFromDimer::RATE());
    assert_amorph_atom(s.x-1, 0, 2, 1, 2);
    assert_atom(s.x-1, 0, 2, 4, 0);
    assert_atom(s.x-2, 0, 1, 3, 1);
    assert_atom(s.x-2, s.y-1, 1, 3, 0);

    // 95
    Handbook::mc().doOneOfOne(MIGRATION_DOWN_IN_GAP_FROM_DIMER);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, s.y-1, 1);
    assert_rate(19 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                TwoBridgesToHighBridge::RATE() +
                DimerDrop::RATE() +
                AdsMethylToDimer::RATE() +
                AdsMethylTo111::RATE());
    assert_atom(0, 0, 2, 2, 1);
    assert_atom(s.x-1, 0, 2, 3, 1);
    assert_atom(s.x-2, 0, 2, 3, 0);
    assert_atom(s.x-2, 0, 1, 4, 0);
    assert_atom(s.x-2, 1, 1, 4, 0);
    assert_atom(s.x-2, s.y-1, 1, 3, 1);

    // 96
    Handbook::mc().doOneOfOne(DIMER_DROP);
    Handbook::mc().doOneOfOne(TWO_BRIDGES_TO_HIGH_BRIDGE);
    assert_rate(19 * SurfaceActivation::RATE() +
                5 * SurfaceDeactivation::RATE() +
                2 * DimerFormation::RATE() +
                TwoBridgesToHighBridge::RATE() +
                HighBridgeToTwoBridges::RATE() +
                HighBridgeToMethyl::RATE() +
                AdsMethylTo111::RATE());
    assert_atom(s.x-1, 0, 2, 2, 2);
    assert_atom(s.x-2, 0, 2, 2, 1);
    assert_atom(s.x-2, 0, 1, 3, 1);
    assert_atom(s.x-2, s.y-1, 1, 4, 0);
    assert_amorph_atom(s.x-2, s.y-1, 1, 2, 0);

    // 97
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_TO_METHYL);
    Handbook::mc().doOneOfOne(DES_METHYL_FROM_DIMER);
    Handbook::mc().doOneOfOne(DIMER_DROP_NEAR_BRIDGE);
    Handbook::mc().doOneOfOne(TWO_BRIDGES_TO_HIGH_BRIDGE);
    Handbook::mc().doOneOfOne(DIMER_FORMATION);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, s.y-1, 1);
    assert_rate(18 * SurfaceActivation::RATE() +
                4 * SurfaceDeactivation::RATE() +
                2 * HighBridgeToMethyl::RATE() +
                HighBridgeToTwoBridges::RATE() +
                HighBridgeStandToOneBridge::RATE() +
                NextLevelBridgeToHighBridge::RATE() +
                DimerDrop::RATE() +
                AdsMethylToDimer::RATE() +
                AdsMethylTo111::RATE());
    assert_atom(0, 0, 2, 3, 0);
    assert_atom(s.x-1, 0, 2, 3, 1);
    assert_atom(s.x-2, s.y-1, 1, 2, 1);
    assert_atom(s.x-2, 0, 1, 4, 0);
    assert_amorph_atom(s.x-2, 0, 1, 2, 1);

    // 98
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, s.y-1, 1);
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_TO_METHYL);
    Handbook::mc().doOneOfOne(DES_METHYL_FROM_DIMER);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, 0, 1);
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, 0, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, s.y-1, 1);
    assert_rate(17 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                2 * MethylOnDimerActivation::RATE() +
                MethylOnDimerDeactivation::RATE() +
                DesMethylFromDimer::RATE() +
                MethylToHighBridge::RATE() +
                MigrationDownAtDimerFromDimer::RATE() +
                DimerDropNearBridge::RATE() +
                AdsMethylToDimer::RATE());
    assert_atom(s.x-2, s.y-1, 1, 2, 1);
    assert_atom(s.x-2, 0, 1, 3, 1);
    assert_atom(s.x-1, 0, 2, 4, 0);
    assert_amorph_atom(s.x-1, 0, 2, 1, 1);

    // 99
    Handbook::mc().doOneOfOne(MIGRATION_DOWN_AT_DIMER_FROM_DIMER);
    assert_rate(19 * SurfaceActivation::RATE() +
                3 * SurfaceDeactivation::RATE() +
                DimerDrop::RATE() +
                AdsMethylToDimer::RATE());
    assert_atom(0, 0, 2, 2, 1);
    assert_atom(s.x-1, 0, 2, 3, 1);
    assert_atom(s.x-2, 0, 2, 3, 0);
    assert_atom(s.x-2, 0, 1, 3, 0);
    assert_atom(s.x-2, 1, 1, 4, 0);

    // 100
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, 0, 1);
    Handbook::mc().doOneOfOne(DIMER_DROP);
    Handbook::mc().doOneOfOne(TWO_BRIDGES_TO_HIGH_BRIDGE);
    Handbook::mc().doOneOfOne(DIMER_FORMATION);
    assert_rate(18 * SurfaceActivation::RATE() +
                4 * SurfaceDeactivation::RATE() +
                2 * HighBridgeToMethyl::RATE() +
                HighBridgeStandToOneBridge::RATE() +
                HighBridgeToTwoBridges::RATE() +
                NextLevelBridgeToHighBridge::RATE() +
                DimerDrop::RATE() +
                AdsMethylToDimer::RATE() +
                AdsMethylTo111::RATE());
    assert_atom(0, 0, 2, 3, 0);
    assert_atom(s.x-1, 0, 2, 3, 1);
    assert_atom(s.x-2, 1, 1, 3, 1);
    assert_atom(s.x-2, 0, 1, 4, 0);
    assert_amorph_atom(s.x-2, 0, 1, 2, 1);

    // 101
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, s.y-1, 1);
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_TO_METHYL);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, s.y-1, 1);
    Handbook::mc().doOneOfOne(DES_METHYL_FROM_DIMER);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, 0, 1);
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 0, 2);
    assert_rate(17 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                2 * MethylOnDimerActivation::RATE() +
                MethylOnDimerDeactivation::RATE() +
                AdsMethylToDimer::RATE() +
                DesMethylFromDimer::RATE() +
                MethylToHighBridge::RATE() +
                MethylOnDimerHydrogenMigration::RATE() +
                DimerDropNearBridge::RATE());
    assert_atom(s.x-2, s.y-1, 1, 2, 1);
    assert_atom(s.x-2, 0, 1, 3, 0);
    assert_atom(0, 0, 2, 3, 1);
    assert_atom(s.x-1, 0, 2, 4, 0);
    assert_amorph_atom(s.x-1, 0, 2, 1, 1);

    // 102
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    Handbook::mc().doLastOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, 0, 1);
    assert_rate(16 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                4 * MethylOnDimerActivation::RATE() +
                2 * MethylOnDimerDeactivation::RATE() +
                2 * DesMethylFromDimer::RATE() +
                2 * MethylToHighBridge::RATE() +
                MigrationDownAtDimerFromDimer::RATE() +
                AdsMethylToDimer::RATE() +
                DimerDropNearBridge::RATE());
    assert_atom(s.x-2, 0, 1, 3, 1);
    assert_atom(0, 0, 2, 4, 0);
    assert_amorph_atom(0, 0, 2, 1, 1);

    // 103
    Handbook::mc().doLastOfOne(METHYL_TO_HIGH_BRIDGE);
    assert_rate(20 * SurfaceActivation::RATE() +
                4 * SurfaceDeactivation::RATE() +
                DesMethylFromBridge::RATE() +
                FormTwoBond::RATE() +
                MigrationDownAtDimer::RATE() +
                AdsMethylToDimer::RATE() +
                DimerDropNearBridge::RATE());
    assert_atom(s.x-1, 0, 2, 3, 1);
    assert_atom(0, 0, 2, 4, 0);
    assert_amorph_atom(0, 0, 2, 2, 0);

    // 104
    Handbook::mc().doOneOfOne(MIGRATION_DOWN_AT_DIMER);
    assert_rate(20 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                HighBridgeStandToDimer::RATE() +
                AdsMethylToDimer::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-1, 0, 2, 3, 1);
    assert_atom(s.x-2, 0, 2, 3, 0);
    assert_atom(s.x-2, 0, 1, 3, 0);
    assert_atom(s.x-2, 1, 1, 4, 0);

    // 105
    Handbook::mc().doOneOfOne(DIMER_DROP);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x-2, 0, 1);
    assert_rate(19 * SurfaceActivation::RATE() +
                5 * SurfaceDeactivation::RATE() +
                DimerFormation::RATE() +
                HighBridgeToMethyl::RATE() +
                HighBridgeStandToOneBridge::RATE() +
                TwoBridgesToHighBridge::RATE() +
                AdsMethylTo111::RATE() +
                DimerFormationNearBridge::RATE());
    assert_atom(s.x-1, 0, 2, 2, 2);
    assert_atom(s.x-2, 0, 2, 2, 1);
    assert_atom(s.x-2, 0, 1, 3, 1);

    // 106
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_TO_METHYL);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    Handbook::mc().doOneOfOne(TWO_BRIDGES_TO_HIGH_BRIDGE);
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_ONE_BRIDGE);
    assert_rate(17 * SurfaceActivation::RATE() +
                4 * SurfaceDeactivation::RATE() +
                MethylOnDimerActivation::RATE() +
                2 * MethylOnDimerDeactivation::RATE() +
                2 * NextLevelBridgeToHighBridge::RATE() +
                2 * AdsMethylTo111::RATE() +
                AdsMethylToDimer::RATE() +
                DesMethylFromDimer::RATE() +
                MethylOnDimerHydrogenMigration::RATE() +
                MethylToHighBridge::RATE());
    assert_atom(s.x-2, s.y-1, 1, 3, 0);
    assert_atom(s.x-2, 0, 1, 3, 1);
    assert_atom(s.x-2, s.y-1, 2, 2, 1);
    assert_atom(0, 0, 2, 4, 0);
    assert_amorph_atom(0, 0, 2, 1, 2);

    // 107
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x-2, s.y-1, 2);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_DEACTIVATION);
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    Handbook::mc().doLastOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    Handbook::mc().doLastOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    assert_rate(18 * SurfaceActivation::RATE() +
                2 * SurfaceDeactivation::RATE() +
                3 * MethylOnDimerActivation::RATE() +
                3 * MethylOnDimerDeactivation::RATE() +
                2 * MethylToHighBridge::RATE() +
                2 * DesMethylFromDimer::RATE() +
                2 * AdsMethylTo111::RATE() +
                2 * NextLevelBridgeToHighBridge::RATE() +
                MigrationDownInGapFromDimer::RATE());
    assert_atom(s.x-2, s.y-1, 2, 2, 0);
    assert_amorph_atom(0, 0, 2, 1, 1);
    assert_atom(s.x-1, 0, 2, 4, 0);
    assert_amorph_atom(s.x-1, 0, 2, 1, 2);

    // 108
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    assert_rate(21 * SurfaceActivation::RATE() +
                5 * SurfaceDeactivation::RATE() +
                2 * NextLevelBridgeToHighBridge::RATE() +
                2 * AdsMethylTo111::RATE() +
                FormTwoBond::RATE() +
                DesMethylFromBridge::RATE() +
                MigrationDownInGap::RATE());
    assert_atom(s.x-1, 0, 2, 3, 1);
    assert_atom(0, 0, 2, 4, 0);
    assert_amorph_atom(0, 0, 2, 2, 0);

    // 109
    Handbook::mc().doOneOfOne(MIGRATION_DOWN_IN_GAP);
    assert_rate(21 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                AdsMethylToDimer::RATE() +
                HighBridgeStandToDimer::RATE() +
                DimerDrop::RATE());
    assert_atom(s.x-1, 0, 2, 3, 1);
    assert_atom(s.x-2, 0, 2, 3, 0);
    assert_atom(s.x-2, 0, 1, 4, 0);
    assert_atom(s.x-2, 1, 1, 4, 0);

    // 110
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_DIMER);
    assert_rate(21 * SurfaceActivation::RATE() +
                SurfaceDeactivation::RATE() +
                AdsMethylTo111::RATE() +
                BridgeWithDimerToHighBridgeAndDimer::RATE() +
                DimerDropNearBridge::RATE());
    assert_atom(0, 0, 2, 3, 1);
    assert_atom(s.x-1, 0, 2, 4, 0);
    assert_atom(s.x-1, 0, 3, 2, 0);

    delete diamond;
    return 0;
}
