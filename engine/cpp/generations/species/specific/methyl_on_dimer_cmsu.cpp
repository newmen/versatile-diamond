#include "methyl_on_dimer_cmsu.h"
#include "../../reactions/typical/methyl_to_high_bridge.h"
#include "../../reactions/typical/migration_down_at_dimer_from_dimer.h"
#include "methyl_on_dimer_cmssu.h"

const ushort MethylOnDimerCMsu::__indexes[1] = { 0 };
const ushort MethylOnDimerCMsu::__roles[1] = { 26 };

void MethylOnDimerCMsu::find(MethylOnDimerCMu *parent)
{
    Atom *anchor = parent->atom(0);

    if (anchor->is(26))
    {
        if (!anchor->hasRole<MethylOnDimerCMsu>(26))
        {
            create<MethylOnDimerCMsu>(parent);
        }
    }
}

void MethylOnDimerCMsu::findAllChildren()
{
    MethylOnDimerCMssu::find(this);
}

void MethylOnDimerCMsu::findAllReactions()
{
    MethylToHighBridge::find(this);
    MigrationDownAtDimerFromDimer::find(this);
}
