#include "bridge_crs.h"
#include "bridge_crs_cti_cli.h"
#include "../../reactions/typical/ads_methyl_to_111.h"
#include "../../reactions/typical/dimer_formation_near_bridge.h"
#include "../../reactions/typical/high_bridge_to_two_bridges.h"
#include "../../reactions/typical/high_bridge_to_methyl.h"
#include "../../reactions/typical/migration_down_in_gap.h"
#include "../../reactions/typical/migration_down_in_gap_from_111.h"
#include "../../reactions/typical/migration_down_in_gap_from_high_bridge.h"
#include "../../reactions/typical/migration_down_in_gap_from_dimer.h"

const ushort BridgeCRs::__indexes[1] = { 1 };
const ushort BridgeCRs::__roles[1] = { 5 };

void BridgeCRs::find(BridgeCRi *parent)
{
    Atom *anchor = parent->atom(1);
    if (anchor->is(5))
    {
        if (!checkAndFind<BridgeCRs>(anchor, 5))
        {
            create<BridgeCRs>(parent);
        }
    }
}

void BridgeCRs::findAllChildren()
{
    BridgeCRsCTiCLi::find(this);
}

void BridgeCRs::findAllReactions()
{
    AdsMethylTo111::find(this);
    DimerFormationNearBridge::find(this);
    HighBridgeToTwoBridges::find(this);
    HighBridgeToMethyl::find(this);
//    MigrationDownInGap::find(this); // DISABLED
    MigrationDownInGapFrom111::find(this);
    MigrationDownInGapFromHighBridge::find(this);
//    MigrationDownInGapFromDimer::find(this); // DISABLED
}
