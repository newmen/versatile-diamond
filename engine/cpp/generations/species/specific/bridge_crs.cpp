#include "bridge_crs.h"
#include "bridge_crs_cti_cli.h"
#include "../../reactions/typical/dimer_formation_near_bridge.h"
#include "../../reactions/typical/high_bridge_to_two_bridges.h"
#include "../../reactions/typical/high_bridge_to_methyl.h"
#include "../../reactions/typical/migration_down_in_gap.h"
#include "../../reactions/typical/migration_down_in_gap_from_111.h"
#include "../../reactions/typical/migration_down_in_gap_from_high_bridge.h"

const ushort BridgeCRs::__indexes[1] = { 1 };
const ushort BridgeCRs::__roles[1] = { 5 };

void BridgeCRs::find(Bridge *parent)
{
    const uint checkingIndexes[2] = { 1, 2 };

    for (int i = 0; i < 2; ++i)
    {
        Atom *anchor = parent->atom(checkingIndexes[i]);
        if (anchor->is(5))
        {
            if (!checkAndFind<BridgeCRs>(anchor, 5))
            {
                create<BridgeCRs>(checkingIndexes[i], 1, parent);
            }
        }
    }
}

void BridgeCRs::findAllChildren()
{
    BridgeCRsCTiCLi::find(this);
}

void BridgeCRs::findAllReactions()
{
    DimerFormationNearBridge::find(this);
    HighBridgeToTwoBridges::find(this);
    HighBridgeToMethyl::find(this);
    MigrationDownInGap::find(this);
    MigrationDownInGapFrom111::find(this);
    MigrationDownInGapFromHighBridge::find(this);
}
