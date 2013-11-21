#include "methyl_on_dimer_cmu.h"
#include "methyl_on_dimer_cmsu.h"
#include "methyl_on_dimer_cls_cmu.h"

ushort MethylOnDimerCMu::__indexes[1] = { 0 };
ushort MethylOnDimerCMu::__roles[1] = { 31 };

void MethylOnDimerCMu::find(MethylOnDimer *parent)
{
    Atom *anchor = parent->atom(0);

    if (anchor->is(31) && !anchor->is(13))
    {
        if (!checkAndFind(anchor, 31, METHYL_ON_DIMER_CMu))
        {
            createBy<MethylOnDimerCMu>(parent);
        }
    }
}

void MethylOnDimerCMu::findAllChildren()
{
    MethylOnDimerCLsCMu::find(this);
    MethylOnDimerCMsu::find(this);
}
