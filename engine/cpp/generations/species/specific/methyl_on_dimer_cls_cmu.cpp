#include "methyl_on_dimer_cls_cmu.h"
#include "../../reactions/typical/methyl_on_dimer_hydrogen_migration.h"

ushort MethylOnDimerCLsCMu::__indexes[1] = { 4 };
ushort MethylOnDimerCLsCMu::__roles[1] = { 21 };

void MethylOnDimerCLsCMu::find(MethylOnDimerCMu *parent)
{
    Atom *anchor = parent->atom(4);

    if (anchor->is(21))
    {
        if (!anchor->hasRole(21, METHYL_ON_DIMER_CLs_CMu))
        {
            auto spec = new MethylOnDimerCLsCMu(parent);
            spec->store();
        }
    }
}

void MethylOnDimerCLsCMu::findAllReactions()
{
    MethylOnDimerHydrogenMigration::find(this);
}
