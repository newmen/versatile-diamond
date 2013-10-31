#include "dimer_crs.h"
#include "../handbook.h"

void DimerCRs::find(BaseSpec *parent)
{
    Atom *anchors[2] = { parent->atom(0), parent->atom(3) };

    for (int i = 0; i < 2; ++i)
    {
        Atom *anchor = anchors[i];
        if (anchor->isVisited()) continue;

        if (anchor->is(21))
        {
            if (!anchor->prevIs(21))
            {
                auto spec = new DimerCRs(DIMER_CRs, parent);

#ifdef PRINT
                spec->wasFound();
#endif // PRINT

                anchor->describe(21, spec);
                spec->findChildren();
            }
        }
        else
        {
            if (anchor->prevIs(21))
            {
                auto spec = anchor->specificSpecByRole(21, DIMER_CRs);
                spec->removeReactions();

#ifdef PRINT
                spec->wasForgotten();
#endif // PRINT

                anchor->forget(21, spec);
                Handbook::scavenger().storeSpec<DIMER_CRs>(spec);
            }
        }
    }
}

DimerCRs::DimerCRs(ushort type, BaseSpec *parent) : SpecificSpec(type, parent)
{
}

void DimerCRs::findChildren()
{
}
