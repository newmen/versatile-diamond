#include "methyl_on_dimer_cmssu.h"
#include "../../reactions/typical/migration_down_in_gap_from_dimer.h"

const ushort MethylOnDimerCMssu::__indexes[1] = { 0 };
const ushort MethylOnDimerCMssu::__roles[1] = { 27 };

void MethylOnDimerCMssu::find(MethylOnDimerCMsu *parent)
{
    Atom *anchor = parent->atom(0);

    if (anchor->is(27))
    {
        if (!anchor->hasRole<MethylOnDimerCMssu>(27))
        {
            create<MethylOnDimerCMssu>(parent);
        }
    }
}

void MethylOnDimerCMssu::findAllTypicalReactions()
{
    MigrationDownInGapFromDimer::find(this);
}
