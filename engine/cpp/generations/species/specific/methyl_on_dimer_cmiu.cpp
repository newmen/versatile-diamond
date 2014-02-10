#include "methyl_on_dimer_cmiu.h"
#include "../../reactions/typical/des_methyl_from_dimer.h"
#include "methyl_on_dimer_cmsiu.h"
#include "methyl_on_dimer_cls_cmhiu.h"

const ushort MethylOnDimerCMiu::__indexes[1] = { 0 };
const ushort MethylOnDimerCMiu::__roles[1] = { 25 };

#ifdef PRINT
const char *MethylOnDimerCMiu::name() const
{
    static const char value[] = "methyl_on_dimer(cm: i, cm: u)";
    return value;
}
#endif // PRINT

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
