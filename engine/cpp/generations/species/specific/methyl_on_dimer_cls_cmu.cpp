#include "methyl_on_dimer_cls_cmu.h"
#include "../../reactions/typical/methyl_on_dimer_hydrogen_migration.h"

ushort MethylOnDimerCLsCMu::__indexes[1] = { 4 };
ushort MethylOnDimerCLsCMu::__roles[1] = { 21 };

void MethylOnDimerCLsCMu::find(MethylOnDimerCMu *parent)
{
    Atom *anchor = parent->atom(4);
    if (anchor->is(21))
    {
        if (!anchor->hasRole<MethylOnDimerCLsCMu>(21))
        {
            createBy<MethylOnDimerCLsCMu>(parent);
        }
    }
}

void MethylOnDimerCLsCMu::findAllReactions()
{
    MethylOnDimerHydrogenMigration::find(this);
}
