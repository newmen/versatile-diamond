#include "methyl_on_dimer_cls_cmhiu.h"
#include "../../reactions/typical/methyl_on_dimer_hydrogen_migration.h"

template <> const ushort MethylOnDimerCLsCMhiu::Base::__indexes[2] = { 4, 0 };
template <> const ushort MethylOnDimerCLsCMhiu::Base::__roles[2] = { 21, 35 };

#if defined(PRINT) || defined(SPEC_PRINT) || defined(JSONLOG)
const char *MethylOnDimerCLsCMhiu::name() const
{
    static const char value[] = "methyl_on_dimer(cl: *, cm: H, cm: i, cm: u)";
    return value;
}
#endif // PRINT || SPEC_PRINT || JSONLOG

void MethylOnDimerCLsCMhiu::find(MethylOnDimerCMiu *parent)
{
    Atom *anchors[2];
    for (int i = 0; i < 2; ++i)
    {
        anchors[i] = parent->atom(__indexes[i]);
    }

    if (anchors[0]->is(21) && anchors[1]->is(35))
    {
        if (!anchors[0]->hasRole(METHYL_ON_DIMER_CLs_CMhiu, 21) || !anchors[1]->hasRole(METHYL_ON_DIMER_CLs_CMhiu, 35))
        {
            create<MethylOnDimerCLsCMhiu>(parent);
        }
    }
}

void MethylOnDimerCLsCMhiu::findAllTypicalReactions()
{
    MethylOnDimerHydrogenMigration::find(this);
}
