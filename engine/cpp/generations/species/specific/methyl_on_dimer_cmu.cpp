#include "methyl_on_dimer_cmu.h"
#include "../../reactions/typical/des_methyl_from_dimer.h"
#include "methyl_on_dimer_cmsu.h"
#include "methyl_on_dimer_cls_cmu.h"

const ushort MethylOnDimerCMu::__indexes[1] = { 0 };
const ushort MethylOnDimerCMu::__roles[1] = { 31 };

void MethylOnDimerCMu::find(MethylOnDimer *parent)
{
    Atom *anchor = parent->atom(0);
    if (anchor->is(31) && !anchor->is(13))
    {
        if (!anchor->checkAndFind(METHYL_ON_DIMER_CMu, 31))
        {
            create<MethylOnDimerCMu>(parent);
        }
    }
}

void MethylOnDimerCMu::findAllChildren()
{
    MethylOnDimerCLsCMu::find(this);
    MethylOnDimerCMsu::find(this);
}

void MethylOnDimerCMu::findAllTypicalReactions()
{
    DesMethylFromDimer::find(this);
}
