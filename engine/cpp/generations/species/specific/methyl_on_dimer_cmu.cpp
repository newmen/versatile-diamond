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
        auto spec = anchor->specByRole(31, METHYL_ON_DIMER_CMu);
        if (spec)
        {
            static_cast<MethylOnDimerCMu *>(spec)->correspondFindChildren();
        }
        else
        {
            spec = new MethylOnDimerCMu(parent);
            spec->store();
        }
    }
}

void MethylOnDimerCMu::findChildren()
{
    MethylOnDimerCLsCMu::find(this);
    MethylOnDimerCMsu::find(this);
}
