#include "dimer_crs.h"
#include "dimer_crs_cli.h"
#include "../../reactions/typical/ads_methyl_to_dimer.h"
#include "../../reactions/typical/migration_down_at_dimer.h"
#include "../../reactions/typical/migration_down_at_dimer_from_111.h"
#include "../../reactions/typical/migration_down_at_dimer_from_high_bridge.h"
#include "../../reactions/typical/migration_down_at_dimer_from_dimer.h"

const ushort DimerCRs::__indexes[1] = { 0 };
const ushort DimerCRs::__roles[1] = { 21 };

void DimerCRs::find(Dimer *parent)
{
    uint indexes[2] = { 0, 3 };

    for (int i = 0; i < 2; ++i)
    {
        Atom *anchor = parent->atom(indexes[i]);
        if (anchor->isVisited()) continue; // because no children species

        if (anchor->is(21))
        {
            if (!anchor->hasRole<DimerCRs>(21))
            {
                create<DimerCRs>(indexes[i], parent);
            }
        }
    }
}

void DimerCRs::findAllChildren()
{
    DimerCRsCLi::find(this);
}

void DimerCRs::findAllReactions()
{
    AdsMethylToDimer::find(this);
//    MigrationDownAtDimer::find(this); // DISABLED
    MigrationDownAtDimerFrom111::find(this);
    MigrationDownAtDimerFromHighBridge::find(this);
//    MigrationDownAtDimerFromDimer::find(this); // DISABLED
}
