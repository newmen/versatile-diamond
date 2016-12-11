#include "methyl_on_dimer_cmiu.h"
#include "../../reactions/typical/des_methyl_from_dimer.h"
#include "../../reactions/ubiquitous/local/methyl_on_dimer_activation.h"
#include "methyl_on_dimer_cmsiu.h"
#include "methyl_on_dimer_cls_cmhiu.h"

template <> const ushort MethylOnDimerCMiu::Base::__indexes[1] = { 0 };
template <> const ushort MethylOnDimerCMiu::Base::__roles[1] = { 25 };

#if defined(PRINT) || defined(SERIALIZE)
const char *MethylOnDimerCMiu::name() const
{
    static const char value[] = "methyl_on_dimer(cm: i, cm: u)";
    return value;
}
#endif // PRINT || SERIALIZE

void MethylOnDimerCMiu::find(MethylOnDimer *parent)
{
    Atom *anchor = parent->atom(0);
    if (anchor->is(25))
    {
        if (!anchor->checkAndFind(METHYL_ON_DIMER_CMiu, 25))
        {
            create<MethylOnDimerCMiu>(parent);
        }
    }
}

void MethylOnDimerCMiu::findAllChildren()
{
    MethylOnDimerCLsCMhiu::find(this);
    MethylOnDimerCMsiu::find(this);
}

void MethylOnDimerCMiu::findAllTypicalReactions()
{
    DesMethylFromDimer::find(this);
}

void MethylOnDimerCMiu::concretizeLocal(Atom *target) const
{
    MethylOnDimerActivation::concretize(target);
}

void MethylOnDimerCMiu::unconcretizeLocal(Atom *target) const
{
    MethylOnDimerActivation::unconcretize(target);
}
