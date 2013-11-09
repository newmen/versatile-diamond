#include "dimer_cri_cli.h"
#include "../handbook.h"
#include "../reactions/typical/dimer_drop.h"

void DimerCRiCLi::find(Dimer *parent)
{
    Atom *anchors[2] = { parent->atom(0), parent->atom(3) };

    if (anchors[0]->is(20) && anchors[1]->is(20))
    {
        if (!anchors[0]->hasRole(20, DIMER_CRi_CLi) && !anchors[1]->hasRole(20, DIMER_CRi_CLi))
        {
            auto spec = new DimerCRiCLi(DIMER_CRi_CLi, parent);

#ifdef PRINT
            spec->wasFound();
#endif // PRINT

            anchors[0]->describe(20, spec);
            anchors[1]->describe(20, spec);

            spec->findChildren();
        }
    }
    else
    {
        if (anchors[0]->hasRole(20, DIMER_CRi_CLi) && anchors[1]->hasRole(20, DIMER_CRi_CLi))
        {
            auto spec = anchors[0]->specificSpecByRole(20, DIMER_CRi_CLi);
            spec->removeReactions();

#ifdef PRINT
            spec->wasForgotten();
#endif // PRINT

            anchors[0]->forget(20, spec);
            anchors[1]->forget(20, spec);
            
            Handbook::scavenger().markSpec<DIMER_CRi_CLi>(spec);
        }
    }
}

void DimerCRiCLi::findChildren()
{
    DimerDrop::find(this);
}
