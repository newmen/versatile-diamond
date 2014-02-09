#include "methyl_on_dimer_cmssiu.h"
#include "../../reactions/typical/migration_down_in_gap_from_dimer.h"

const ushort MethylOnDimerCMssiu::__indexes[1] = { 0 };
const ushort MethylOnDimerCMssiu::__roles[1] = { 27 };

#ifdef PRINT
const char *MethylOnDimerCMssiu::name() const
{
    static const char value[] = "methyl_on_dimer(cm: **, cm: i, cm: u)";
    return value;
}
#endif // PRINT

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
