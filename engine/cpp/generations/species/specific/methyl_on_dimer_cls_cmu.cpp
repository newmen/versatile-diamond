#include "methyl_on_dimer_cls_cmu.h"
#include "../../reactions/typical/methyl_on_dimer_hydrogen_migration.h"

const ushort MethylOnDimerCLsCMu::__indexes[1] = { 4 };
const ushort MethylOnDimerCLsCMu::__roles[1] = { 21 };

#ifdef PRINT
const char *MethylOnDimerCLsCMu::name() const
{
    static const char value[] = "methyl_on_dimer(cl: *, cm: u)";
    return value;
}
#endif // PRINT

void MethylOnDimerCLsCMu::find(MethylOnDimerCMu *parent)
{
    Atom *anchor = parent->atom(4);
    if (anchor->is(21))
    {
        if (!anchor->hasRole(METHYL_ON_DIMER_CLs_CMu, 21))
        {
            create<MethylOnDimerCLsCMu>(parent);
        }
    }
}

void MethylOnDimerCLsCMu::findAllTypicalReactions()
{
    MethylOnDimerHydrogenMigration::find(this);
}
