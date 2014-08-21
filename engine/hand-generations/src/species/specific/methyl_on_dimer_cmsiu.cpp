#include "methyl_on_dimer_cmsiu.h"
#include "../../reactions/typical/methyl_to_high_bridge.h"
#include "../../reactions/typical/migration_down_at_dimer_from_dimer.h"
#include "../../reactions/typical/migration_through_dimers_row.h"
#include "../../reactions/ubiquitous/local/methyl_on_dimer_deactivation.h"
#include "methyl_on_dimer_cmssiu.h"

const ushort MethylOnDimerCMsiu::Base::__indexes[1] = { 0 };
const ushort MethylOnDimerCMsiu::Base::__roles[1] = { 26 };

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
        if (!anchor->checkAndFind(METHYL_ON_DIMER_CMsiu, 26))
        {
            create<MethylOnDimerCMsiu>(parent);
        }
    }
}

void MethylOnDimerCMsiu::findAllChildren()
{
    MethylOnDimerCMssiu::find(this);
}

void MethylOnDimerCMsiu::findAllTypicalReactions()
{
    MethylToHighBridge::find(this);
    MigrationDownAtDimerFromDimer::find(this);
    MigrationThroughDimersRow::find(this);
}

void MethylOnDimerCMsiu::concretizeLocal(Atom *target) const
{
    MethylOnDimerDeactivation::concretize(target);
}

void MethylOnDimerCMsiu::unconcretizeLocal(Atom *target) const
{
    MethylOnDimerDeactivation::unconcretize(target);
}
