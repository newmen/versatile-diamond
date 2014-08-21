#include "dimer_crs.h"
#include "dimer_crs_cli.h"
#include "../../reactions/typical/ads_methyl_to_dimer.h"
#include "../../reactions/typical/migration_down_at_dimer.h"
#include "../../reactions/typical/migration_down_at_dimer_from_111.h"
#include "../../reactions/typical/migration_down_at_dimer_from_high_bridge.h"
#include "../../reactions/typical/migration_down_at_dimer_from_dimer.h"
#include "../../reactions/typical/migration_through_dimers_row.h"

const ushort DimerCRs::Base::__indexes[1] = { 0 };
const ushort DimerCRs::Base::__roles[1] = { 21 };

#ifdef PRINT
const char *DimerCRs::name() const
{
    static const char value[] = "dimer(cr: *)";
    return value;
}
#endif // PRINT

void DimerCRs::find(Dimer *parent)
{
    parent->eachSymmetry([](ParentSpec *specie) {
        Atom *anchor = specie->atom(0);

        if (!anchor->isVisited() && anchor->is(21))
        {
            if (!anchor->checkAndFind(DIMER_CRs, 21))
            {
                create<DimerCRs>(specie);
            }
        }
    });
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
    MigrationThroughDimersRow::find(this);
}
