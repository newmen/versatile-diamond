#include "dimer_cri_cli.h"
#include "../../reactions/typical/dimer_drop.h"

ushort DimerCRiCLi::__indexes[2] = { 0, 3 };
ushort DimerCRiCLi::__roles[2] = { 20, 20 };

void DimerCRiCLi::find(Dimer *parent)
{
    Atom *anchors[2] = { parent->atom(0), parent->atom(3) };

    if (anchors[0]->is(20) && anchors[1]->is(20))
    {
        if (!anchors[0]->hasRole(20, DIMER_CRi_CLi) && !anchors[1]->hasRole(20, DIMER_CRi_CLi))
        {
            auto spec = new DimerCRiCLi(parent);
            spec->store();
        }
    }
}

void DimerCRiCLi::findChildren()
{
    DimerDrop::find(this);
}
