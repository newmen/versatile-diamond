#include "methyl_on_dimer_cls_cmhiu.h"
#include "../../reactions/typical/methyl_on_dimer_hydrogen_migration.h"

const ushort MethylOnDimerCLsCMhiu::__indexes[2] = { 4, 0 };
const ushort MethylOnDimerCLsCMhiu::__roles[2] = { 21, 35 };

#ifdef PRINT
const char *MethylOnDimerCLsCMhiu::name() const
{
    static const char value[] = "methyl_on_dimer(cl: *, cm: H, cm: i, cm: u)";
    return value;
}
#endif // PRINT

void MethylOnDimerCLsCMhiu::find(MethylOnDimerCMiu *parent)
{
    Atom *anchors[2];
    for (int i = 0; i < 2; ++i)
    {
        anchors[i] = parent->atom(__indexes[i]);
    }

    if (anchors[0]->is(21) && anchors[1]->is(35))
    {
        if (!anchors[0]->hasRole(METHYL_ON_DIMER_CLs_CMhiu, 21) && !anchors[1]->hasRole(METHYL_ON_DIMER_CLs_CMhiu, 35))
        {
            create<MethylOnDimerCLsCMhiu>(parent);
        }
    }
}

void MethylOnDimerCLsCMhiu::findAllTypicalReactions()
{
    MethylOnDimerHydrogenMigration::find(this);
}
