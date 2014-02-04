#include "methyl_on_dimer_cls_cmu.h"
#include "../../reactions/typical/methyl_on_dimer_hydrogen_migration.h"

const ushort MethylOnDimerCLsCMu::__indexes[1] = { 4 };
const ushort MethylOnDimerCLsCMu::__roles[1] = { 21 };

void MethylOnDimerCLsCMu::find(MethylOnDimerCMu *parent)
{
    Atom *anchor = parent->atom(4);
    if (anchor->is(21))
    {
        if (!anchor->hasRole<MethylOnDimerCLsCMu>(21))
        {
            create<MethylOnDimerCLsCMu>(parent);
        }
    }
}

void MethylOnDimerCLsCMu::findAllTypicalReactions()
{
    MethylOnDimerHydrogenMigration::find(this);
}
