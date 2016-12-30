#include "methyl_on_dimer_cmssiu.h"
#include "../../reactions/typical/migration_down_in_gap_from_dimer.h"

template <> const ushort MethylOnDimerCMssiu::Base::__indexes[1] = { 0 };
template <> const ushort MethylOnDimerCMssiu::Base::__roles[1] = { 27 };

#if defined(PRINT) || defined(SPEC_PRINT) || defined(SERIALIZE)
const char *MethylOnDimerCMssiu::name() const
{
    static const char value[] = "methyl_on_dimer(cm: **, cm: i, cm: u)";
    return value;
}
#endif // PRINT || SPEC_PRINT || SERIALIZE

void MethylOnDimerCMssiu::find(MethylOnDimerCMsiu *parent)
{
    Atom *anchor = parent->atom(0);

    if (anchor->is(27))
    {
        if (!anchor->hasRole(METHYL_ON_DIMER_CMssiu, 27))
        {
            create<MethylOnDimerCMssiu>(parent);
        }
    }
}

void MethylOnDimerCMssiu::findAllTypicalReactions()
{
    MigrationDownInGapFromDimer::find(this);
}
