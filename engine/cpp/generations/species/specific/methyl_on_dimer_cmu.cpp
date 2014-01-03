#include "methyl_on_dimer_cmu.h"
#include "methyl_on_dimer_cmsu.h"
#include "methyl_on_dimer_cls_cmu.h"

const ushort MethylOnDimerCMu::__indexes[1] = { 0 };
const ushort MethylOnDimerCMu::__roles[1] = { 31 };

void MethylOnDimerCMu::find(MethylOnDimer *parent)
{
    Atom *anchor = parent->atom(0);
    if (anchor->is(31) && !anchor->is(13))
    {
        if (!checkAndFind<MethylOnDimerCMu>(anchor, 31))
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
