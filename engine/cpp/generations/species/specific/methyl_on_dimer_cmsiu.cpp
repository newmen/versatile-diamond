#include "methyl_on_dimer_cmsiu.h"
#include "../../reactions/typical/methyl_to_high_bridge.h"
#include "../../reactions/typical/migration_down_at_dimer_from_dimer.h"
#include "methyl_on_dimer_cmssiu.h"

const ushort MethylOnDimerCMsiu::__indexes[1] = { 0 };
const ushort MethylOnDimerCMsiu::__roles[1] = { 26 };

#ifdef PRINT
const char *MethylOnDimerCMsiu::name() const
{
    static const char value[] = "methyl_on_dimer(cm: *, cm: i, cm: u)";
    return value;
}
#endif // PRINT

void MethylOnDimerCMsiu::find(MethylOnDimerCMiu *parent)
{
    Atom *anchor = parent->atom(0);

    if (anchor->is(26))
    {
        if (!anchor->hasRole(METHYL_ON_DIMER_CMsiu, 26))
        {
            create<MethylOnDimerCMsiu>(parent);
        }
    }
}

void MethylOnDimerCMsiu::findAllChildren()
{
//    MethylOnDimerCMssiu::find(this); // DISABLED: MigrationDownInGapFromDimer
}

void MethylOnDimerCMsiu::findAllTypicalReactions()
{
    MethylToHighBridge::find(this);
//    MigrationDownAtDimerFromDimer::find(this); // DISABLED
}
