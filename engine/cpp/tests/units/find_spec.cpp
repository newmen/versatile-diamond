#include <generations/handbook.h>
#include <generations/builders/atom_builder.h>
#include <generations/phases/diamond.h>

#include <generations/reactions/lateral/dimer_drop_at_end.h>
#include <generations/reactions/lateral/dimer_drop_in_middle.h>
#include <generations/reactions/lateral/dimer_formation_at_end.h>
#include <generations/reactions/lateral/dimer_formation_in_middle.h>
#include <generations/reactions/typical/abs_hydrogen_from_gap.h>
#include <generations/reactions/typical/ads_methyl_to_111.h>
#include <generations/reactions/typical/ads_methyl_to_dimer.h>
#include <generations/reactions/typical/bridge_with_dimer_to_high_bridge_and_dimer.h>
#include <generations/reactions/typical/des_methyl_from_111.h>
#include <generations/reactions/typical/des_methyl_from_bridge.h>
#include <generations/reactions/typical/des_methyl_from_dimer.h>
#include <generations/reactions/typical/dimer_drop.h>
#include <generations/reactions/typical/dimer_drop_near_bridge.h>
#include <generations/reactions/typical/dimer_formation.h>
#include <generations/reactions/typical/dimer_formation_near_bridge.h>
#include <generations/reactions/typical/form_two_bond.h>
#include <generations/reactions/typical/high_bridge_stand_to_dimer.h>
#include <generations/reactions/typical/high_bridge_stand_to_one_bridge.h>
#include <generations/reactions/typical/high_bridge_to_methyl.h>
#include <generations/reactions/typical/high_bridge_to_two_bridges.h>
#include <generations/reactions/typical/lookers/near_activated_dimer.h>
#include <generations/reactions/typical/lookers/near_gap.h>
#include <generations/reactions/typical/lookers/near_high_bridge.h>
#include <generations/reactions/typical/lookers/near_methyl_on_111.h>
#include <generations/reactions/typical/lookers/near_methyl_on_bridge.h>
#include <generations/reactions/typical/lookers/near_methyl_on_bridge_cbi.h>
#include <generations/reactions/typical/lookers/near_methyl_on_dimer.h>
#include <generations/reactions/typical/lookers/near_part_of_gap.h>
#include <generations/reactions/typical/methyl_on_dimer_hydrogen_migration.h>
#include <generations/reactions/typical/methyl_to_high_bridge.h>
// #include <generations/reactions/typical/migration_down_at_dimer.h>
#include <generations/reactions/typical/migration_down_at_dimer_from_111.h>
// #include <generations/reactions/typical/migration_down_at_dimer_from_dimer.h>
#include <generations/reactions/typical/migration_down_at_dimer_from_high_bridge.h>
// #include <generations/reactions/typical/migration_down_in_gap.h>
#include <generations/reactions/typical/migration_down_in_gap_from_111.h>
// #include <generations/reactions/typical/migration_down_in_gap_from_dimer.h>
#include <generations/reactions/typical/migration_down_in_gap_from_high_bridge.h>
#include <generations/reactions/typical/next_level_bridge_to_high_bridge.h>
#include <generations/reactions/typical/two_bridges_to_high_bridge.h>
#include <generations/reactions/ubiquitous/local/methyl_on_dimer_activation.h>
#include <generations/reactions/ubiquitous/local/methyl_on_dimer_deactivation.h>
#include <generations/reactions/ubiquitous/surface_activation.h>
#include <generations/reactions/ubiquitous/surface_deactivation.h>

#include "../support/open_diamond.h"

#include <iostream>
using namespace std;

void printRate()
{
#ifdef PRINT
    cout << "\n\n\n" << endl;
#endif // PRINT
    cout << Handbook::mc().totalRate() << endl;
#ifdef PRINT
    cout << "\n\n\n" << endl;
#endif // PRINT
}

void assert_rate(double rate)
{
    printRate();

    static const double EPS = 1e-3;

    double delta = abs(Handbook::mc().totalRate() - rate);
    assert(delta < EPS);
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
    assert_rate(4 * SurfaceActivation::RATE);

    // 2
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 0, 1);
    assert_rate(3 * SurfaceActivation::RATE +
                SurfaceDeactivation::RATE);

    // 3
    buildBridge(0, 1, 1);
    assert_rate(7 * SurfaceActivation::RATE +
                SurfaceDeactivation::RATE);

    // 4
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 1, 1);
    assert_rate(6 * SurfaceActivation::RATE +
                2 * SurfaceDeactivation::RATE +
                DimerFormation::RATE);

    // 5
    buildBridge(0, s.y - 1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, s.y - 1, 1);
    assert_rate(9 * SurfaceActivation::RATE +
                3 * SurfaceDeactivation::RATE +
                2 * DimerFormation::RATE);

    // 6
    Handbook::mc().doOneOfOne(DIMER_FORMATION);
    assert_rate(9 * SurfaceActivation::RATE +
                SurfaceDeactivation::RATE +
                DimerDrop::RATE);

    // 7
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 0, 1);
    assert_rate(8 * SurfaceActivation::RATE +
                2 * SurfaceDeactivation::RATE +
                DimerDrop::RATE +
                AdsMethylToDimer::RATE);

    // 8
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    assert_rate(8 * SurfaceActivation::RATE +
                SurfaceDeactivation::RATE +
                3 * MethylOnDimerActivation::RATE +
                DesMethylFromDimer::RATE);

    // 9
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 1, 1);
    assert_rate(7 * SurfaceActivation::RATE +
                2 * SurfaceDeactivation::RATE +
                3 * MethylOnDimerActivation::RATE +
                AdsMethylToDimer::RATE +
                MethylOnDimerHydrogenMigration::RATE +
                DesMethylFromDimer::RATE);

    // 10
    Handbook::mc().doOneOfOne(METHYL_ON_DIMER_HYDROGEN_MIGRATION);
    assert_rate(8 * SurfaceActivation::RATE +
                SurfaceDeactivation::RATE +
                2 * MethylOnDimerActivation::RATE +
                MethylOnDimerDeactivation::RATE +
                MethylToHighBridge::RATE +
                DesMethylFromDimer::RATE);

    // 11
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    assert_rate(10 * SurfaceActivation::RATE +
                2 * SurfaceDeactivation::RATE +
                2 * HighBridgeStandToOneBridge::RATE +
                2 * HighBridgeToMethyl::RATE);

    // 12
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, s.y - 1, 1);
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_ONE_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, s.y - 1, 1);
    assert_rate(10 * SurfaceActivation::RATE +
                2 * SurfaceDeactivation::RATE +
                NextLevelBridgeToHighBridge::RATE +
                DimerFormationNearBridge::RATE +
                AdsMethylTo111::RATE);

    // 13
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 1, 1);
    assert_rate(9 * SurfaceActivation::RATE +
                3 * SurfaceDeactivation::RATE +
                2 * NextLevelBridgeToHighBridge::RATE +
                2 * AdsMethylTo111::RATE +
                DimerFormationNearBridge::RATE);

    // 14
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, 0, 1);
    assert_rate(10 * SurfaceActivation::RATE +
                2 * SurfaceDeactivation::RATE +
                NextLevelBridgeToHighBridge::RATE +
                AdsMethylTo111::RATE);

    // 15
    Handbook::mc().doOneOfOne(NEXT_LEVEL_BRIDGE_TO_HIGH_BRIDGE);
    assert_rate(10 * SurfaceActivation::RATE +
                2 * SurfaceDeactivation::RATE +
                HighBridgeStandToOneBridge::RATE +
                DimerFormation::RATE +
                HighBridgeToMethyl::RATE);

    // 16
    Handbook::mc().doOneOfOne(DIMER_FORMATION);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 0, 1);
    assert_rate(9 * SurfaceActivation::RATE +
                SurfaceDeactivation::RATE +
                DimerDrop::RATE +
                AdsMethylToDimer::RATE +
                HighBridgeStandToDimer::RATE);

    // 17
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, s.y - 1, 1);
    Handbook::mc().doOneOfOne(METHYL_ON_DIMER_HYDROGEN_MIGRATION);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, s.y - 1, 1);
    assert_rate(8 * SurfaceActivation::RATE +
                SurfaceDeactivation::RATE +
                2 * MethylOnDimerActivation::RATE +
                MethylOnDimerDeactivation::RATE +
                MethylToHighBridge::RATE +
                AdsMethylToDimer::RATE +
                MethylOnDimerHydrogenMigration::RATE +
                DesMethylFromDimer::RATE);

    // 18
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    assert_rate(8 * SurfaceActivation::RATE +
                5 * MethylOnDimerActivation::RATE +
                2 * DesMethylFromDimer::RATE +
                MethylOnDimerDeactivation::RATE +
                MethylToHighBridge::RATE);

    // 19
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    assert_rate(13 * SurfaceActivation::RATE +
                SurfaceDeactivation::RATE +
                DesMethylFromBridge::RATE);

    // 20
    Handbook::mc().doOneOfOne(DES_METHYL_FROM_BRIDGE);
    assert_rate(10 * SurfaceActivation::RATE +
                2 * SurfaceDeactivation::RATE +
                HighBridgeStandToOneBridge::RATE +
                HighBridgeToMethyl::RATE);

    // 21
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_ONE_BRIDGE);
    assert_rate(10 * SurfaceActivation::RATE +
                2 * SurfaceDeactivation::RATE +
                2 * NextLevelBridgeToHighBridge::RATE +
                2 * AdsMethylTo111::RATE +
                HighBridgeToTwoBridges::RATE +
                HighBridgeToMethyl::RATE);

    // 22
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_TWO_BRIDGES);
    assert_rate(10 * SurfaceActivation::RATE +
                2 * SurfaceDeactivation::RATE +
                2 * TwoBridgesToHighBridge::RATE +
                2 * AdsMethylTo111::RATE);

    // 23
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, s.y - 1, 1);
    assert_rate(11 * SurfaceActivation::RATE +
                SurfaceDeactivation::RATE +
                TwoBridgesToHighBridge::RATE +
                AdsMethylTo111::RATE);

    // 24
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, s.y - 1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, s.y - 1, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 0, 2);
    assert_rate(8 * SurfaceActivation::RATE +
                4 * SurfaceDeactivation::RATE +
                2 * TwoBridgesToHighBridge::RATE +
                2 * AdsMethylTo111::RATE);

    // 25
    buildBridge(0, 2, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 2, 1);
    assert_rate(11 * SurfaceActivation::RATE +
                5 * SurfaceDeactivation::RATE +
                2 * TwoBridgesToHighBridge::RATE +
                2 * AdsMethylTo111::RATE +
                DimerFormationNearBridge::RATE);

    // 26
    Handbook::mc().doOneOfOne(DIMER_FORMATION_NEAR_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 2, 1);
    assert_rate(10 * SurfaceActivation::RATE +
                4 * SurfaceDeactivation::RATE +
                TwoBridgesToHighBridge::RATE +
                AdsMethylTo111::RATE +
                AdsMethylToDimer::RATE +
                DimerDropNearBridge::RATE);

    // 27
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    assert_rate(10 * SurfaceActivation::RATE +
                3 * SurfaceDeactivation::RATE +
                3 * MethylOnDimerActivation::RATE +
                TwoBridgesToHighBridge::RATE +
                AdsMethylTo111::RATE +
                DesMethylFromDimer::RATE);

    // 28
    buildBridge(s.x - 1, 1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 1, 1, 1);
    buildBridge(s.x - 1, 2, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 1, 2, 1);
    assert_rate(12 * SurfaceActivation::RATE +
                5 * SurfaceDeactivation::RATE +
                3 * MethylOnDimerActivation::RATE +
                TwoBridgesToHighBridge::RATE +
                AdsMethylTo111::RATE +
                DesMethylFromDimer::RATE +
                DimerFormationAtEnd::RATE);

    // 29
    Handbook::mc().doOneOfOne(DIMER_FORMATION_AT_END);
    buildBridge(s.x - 2, 1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 2, 1, 1);
    buildBridge(s.x - 2, 2, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 2, 2, 1);
    assert_rate(14 * SurfaceActivation::RATE +
                5 * SurfaceDeactivation::RATE +
                3 * MethylOnDimerActivation::RATE +
                TwoBridgesToHighBridge::RATE +
                AdsMethylTo111::RATE +
                DesMethylFromDimer::RATE +
                DimerFormationAtEnd::RATE +
                DimerDropAtEnd::RATE);

    // 30
    Handbook::mc().doOneOfOne(DIMER_FORMATION_AT_END);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 1, 2, 1);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    assert_rate(13 * SurfaceActivation::RATE +
                4 * SurfaceDeactivation::RATE +
                2 * MethylOnDimerActivation::RATE +
                MethylOnDimerDeactivation::RATE +
                TwoBridgesToHighBridge::RATE +
                AdsMethylTo111::RATE +
                DesMethylFromDimer::RATE +
                DimerDropInMiddle::RATE +
                DimerDropAtEnd::RATE +
                MethylToHighBridge::RATE +
                AdsMethylToDimer::RATE);

    // 31
    Handbook::mc().doOneOfOne(DIMER_DROP_IN_MIDDLE);
    assert_rate(13 * SurfaceActivation::RATE +
                6 * SurfaceDeactivation::RATE +
                2 * MethylOnDimerActivation::RATE +
                MethylOnDimerDeactivation::RATE +
                TwoBridgesToHighBridge::RATE +
                AdsMethylTo111::RATE +
                DesMethylFromDimer::RATE +
                DimerFormationInMiddle::RATE +
                DimerDrop::RATE +
                MethylToHighBridge::RATE);

    // 32
    Handbook::mc().doOneOfOne(DIMER_FORMATION_IN_MIDDLE);
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    assert_rate(15 * SurfaceActivation::RATE +
                5 * SurfaceDeactivation::RATE +
                2 * TwoBridgesToHighBridge::RATE +
                2 * AdsMethylTo111::RATE +
                2 * DimerDropAtEnd::RATE +
                HighBridgeToTwoBridges::RATE +
                HighBridgeToMethyl::RATE +
                AdsMethylToDimer::RATE);

    // 33
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    assert_rate(15 * SurfaceActivation::RATE +
                4 * SurfaceDeactivation::RATE +
                3 * MethylOnDimerActivation::RATE +
                2 * TwoBridgesToHighBridge::RATE +
                2 * AdsMethylTo111::RATE +
                DesMethylFromDimer::RATE +
                DimerDropAtEnd::RATE +
                HighBridgeToTwoBridges::RATE +
                HighBridgeToMethyl::RATE);

    // 34
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_TWO_BRIDGES);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, 2, 1);
    assert_rate(18 * SurfaceActivation::RATE +
                4 * SurfaceDeactivation::RATE +
                TwoBridgesToHighBridge::RATE +
                AdsMethylTo111::RATE +
                DimerDrop::RATE +
                HighBridgeStandToOneBridge::RATE +
                HighBridgeToMethyl::RATE);

    // 35
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_ONE_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, 0, 1, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 1, 1, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x - 1, 2, 1);
    assert_rate(17 * SurfaceActivation::RATE +
                5 * SurfaceDeactivation::RATE +
                TwoBridgesToHighBridge::RATE +
                AdsMethylTo111::RATE +
                DimerDrop::RATE +
                DimerFormation::RATE);

    // 36
    Handbook::mc().doOneOfOne(DIMER_FORMATION);
    assert_rate(17 * SurfaceActivation::RATE +
                3 * SurfaceDeactivation::RATE +
                2 * DimerDrop::RATE +
                TwoBridgesToHighBridge::RATE +
                AdsMethylTo111::RATE);

    // 37
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, s.y - 1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, s.y - 1, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, 0, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 1, 1, 2);
    assert_rate(19 * SurfaceActivation::RATE +
                SurfaceDeactivation::RATE +
                2 * DimerDrop::RATE +
                AdsMethylToDimer::RATE);

    // 38
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 2, 2, 1);
    assert_rate(18 * SurfaceActivation::RATE +
                SurfaceDeactivation::RATE +
                2 * MethylOnDimerActivation::RATE +
                MethylOnDimerDeactivation::RATE +
                MethylToHighBridge::RATE +
                DesMethylFromDimer::RATE +
                DimerDrop::RATE +
                AdsMethylToDimer::RATE);

    // 39
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    assert_rate(20 * SurfaceActivation::RATE +
                2 * SurfaceDeactivation::RATE +
                HighBridgeToMethyl::RATE +
                HighBridgeStandToOneBridge::RATE +
                MigrationDownAtDimerFromHighBridge::RATE +
                DimerDrop::RATE +
                AdsMethylToDimer::RATE);

    // 40
    Handbook::mc().doOneOfOne(MIGRATION_DOWN_AT_DIMER_FROM_HIGH_BRIDGE);
    assert_rate(20 * SurfaceActivation::RATE +
                2 * SurfaceDeactivation::RATE +
                DimerDrop::RATE +
                AdsMethylToDimer::RATE);

    // 41
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, 0, 1, 2);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x - 1, 1, 2);
    buildBridge(s.x - 1, 0, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 1, 0, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 1, 1, 1);
    assert_rate(22 * SurfaceActivation::RATE +
                2 * SurfaceDeactivation::RATE +
                DimerFormationNearBridge::RATE +
                DimerDrop::RATE +
                AdsMethylTo111::RATE);

    // 42
    Handbook::mc().doOneOfOne(DIMER_FORMATION_NEAR_BRIDGE);
    assert_rate(22 * SurfaceActivation::RATE +
                DimerDropNearBridge::RATE +
                DimerDrop::RATE);

    // 43
    Handbook::mc().doOneOfOne(DIMER_DROP_NEAR_BRIDGE);
    Handbook::mc().doOneOfOne(DIMER_DROP);
    assert_rate(22 * SurfaceActivation::RATE +
                4 * SurfaceDeactivation::RATE +
                DimerFormationNearBridge::RATE +
                DimerFormation::RATE +
                AdsMethylTo111::RATE +
                NextLevelBridgeToHighBridge::RATE);

    // 44
    Handbook::mc().doOneOfOne(DIMER_FORMATION_NEAR_BRIDGE);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 1, 2, 1);
    assert_rate(21 * SurfaceActivation::RATE +
                3 * SurfaceDeactivation::RATE +
                BridgeWithDimerToHighBridgeAndDimer::RATE +
                AdsMethylTo111::RATE +
                DimerDropNearBridge::RATE +
                DimerFormation::RATE);

    // 45
    Handbook::mc().doOneOfOne(BRIDGE_WITH_DIMER_TO_HIGH_BRIDGE_AND_DIMER);
    assert_rate(21 * SurfaceActivation::RATE +
                3 * SurfaceDeactivation::RATE +
                HighBridgeStandToDimer::RATE +
                AdsMethylToDimer::RATE +
                DimerDrop::RATE);

    // 46
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_DIMER);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x - 1, 2, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 1, 0, 1);
    assert_rate(21 * SurfaceActivation::RATE +
                3 * SurfaceDeactivation::RATE +
                AdsMethylToDimer::RATE +
                DimerDropNearBridge::RATE +
                DimerFormation::RATE);

    // 47
    Handbook::mc().doOneOfOne(DIMER_FORMATION);
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    assert_rate(21 * SurfaceActivation::RATE +
                2 * MethylOnDimerActivation::RATE +
                MethylOnDimerDeactivation::RATE +
                DesMethylFromDimer::RATE +
                MethylToHighBridge::RATE +
                DimerDrop::RATE);

    // 48
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    assert_rate(23 * SurfaceActivation::RATE +
                SurfaceDeactivation::RATE +
                HighBridgeToMethyl::RATE +
                HighBridgeToTwoBridges::RATE +
                AdsMethylTo111::RATE +
                DimerDrop::RATE);

    // 49
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_TWO_BRIDGES);
    assert_rate(23 * SurfaceActivation::RATE +
                SurfaceDeactivation::RATE +
                TwoBridgesToHighBridge::RATE +
                AdsMethylTo111::RATE +
                DimerDrop::RATE);

    // 50
    Handbook::mc().doOneOfOne(TWO_BRIDGES_TO_HIGH_BRIDGE);
    buildBridge(s.x - 1, s.y - 1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 1, s.y - 1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_DEACTIVATION, s.x - 1, 1, 1);
    assert_rate(25 * SurfaceActivation::RATE +
                SurfaceDeactivation::RATE +
                HighBridgeToMethyl::RATE +
                HighBridgeStandToOneBridge::RATE +
                DimerDrop::RATE);

    // 51
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_TO_METHYL);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 1, s.y - 1, 1);
    Handbook::mc().doOneOfMul(CORR_SURFACE_ACTIVATION, s.x - 1, 1, 1);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    assert_rate(21 * SurfaceActivation::RATE +
                2 * SurfaceDeactivation::RATE +
                3 * MethylOnDimerDeactivation::RATE +
                MethylToHighBridge::RATE +
                DesMethylFromDimer::RATE +
                AdsMethylToDimer::RATE +
                AdsMethylTo111::RATE +
                DimerDrop::RATE);

    // 52
    Handbook::mc().doOneOfOne(ADS_METHYL_TO_DIMER);
    Handbook::mc().doOneOfMul(CORR_METHYL_ON_DIMER_ACTIVATION);
    assert_rate(21 * SurfaceActivation::RATE +
                SurfaceDeactivation::RATE +
                2 * MethylOnDimerActivation::RATE +
                4 * MethylOnDimerDeactivation::RATE +
                2 * MethylToHighBridge::RATE +
                2 * DesMethylFromDimer::RATE +
                AdsMethylTo111::RATE +
                DimerDrop::RATE);

    // 53
    Handbook::mc().doOneOfOne(METHYL_TO_HIGH_BRIDGE);
    assert_rate(23 * SurfaceActivation::RATE +
                5 * SurfaceDeactivation::RATE +
                HighBridgeToTwoBridges::RATE +
                HighBridgeToMethyl::RATE +
                DesMethylFromBridge::RATE +
                FormTwoBond::RATE +
                AdsMethylTo111::RATE +
                DimerDrop::RATE);

    // 54
    Handbook::mc().doOneOfOne(FORM_TWO_BOND);
    assert_rate(23 * SurfaceActivation::RATE +
                3 * SurfaceDeactivation::RATE +
                HighBridgeToTwoBridges::RATE +
                HighBridgeToMethyl::RATE +
                AdsMethylTo111::RATE +
                DimerDrop::RATE);

    // 55
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_TWO_BRIDGES);
    Handbook::mc().doOneOfOne(HIGH_BRIDGE_STAND_TO_TWO_BRIDGES);
    assert_rate(23 * SurfaceActivation::RATE +
                3 * SurfaceDeactivation::RATE +
                TwoBridgesToHighBridge::RATE +
                AdsMethylTo111::RATE +
                DimerDrop::RATE);

    delete diamond;
    return 0;
}
