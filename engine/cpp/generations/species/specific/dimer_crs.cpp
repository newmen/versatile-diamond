#include "dimer_crs.h"
#include "dimer_crs_cli.h"
#include "../../reactions/typical/ads_methyl_to_dimer.h"
#include "../../reactions/typical/migration_down_at_dimer.h"
#include "../../reactions/typical/migration_down_at_dimer_from_111.h"
#include "../../reactions/typical/migration_down_at_dimer_from_high_bridge.h"
#include "../../reactions/typical/migration_down_at_dimer_from_dimer.h"

const ushort DimerCRs::__indexes[1] = { 0 };
const ushort DimerCRs::__roles[1] = { 21 };

#ifdef PRINT
const char *DimerCRs::name() const
{
    static const char value[] = "dimer(cr: *)";
    return value;
}
#endif // PRINT

void DimerCRs::find(Dimer *parent)
{
    const ushort indexes[2] = { 0, 3 };

    for (int i = 0; i < 2; ++i)
    {
        Atom *anchor = parent->atom(indexes[i]);
        if (anchor->isVisited()) continue; // because no children species

        if (anchor->is(21))
        {
            if (!anchor->hasRole(DIMER_CRs, 21))
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

void DimerCRs::findAllTypicalReactions()
{
    AdsMethylToDimer::find(this);
    MigrationDownAtDimer::find(this);
    MigrationDownAtDimerFrom111::find(this);
    MigrationDownAtDimerFromHighBridge::find(this);
    MigrationDownAtDimerFromDimer::find(this);
}
