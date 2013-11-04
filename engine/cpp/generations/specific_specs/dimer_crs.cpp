#include "dimer_crs.h"
#include "../handbook.h"
#include "../reactions/typical/ads_methyl_to_dimer.h"

void DimerCRs::find(Dimer *target)
{
    uint indexes[2] = { 0, 3 };

    for (int i = 0; i < 2; ++i)
    {
        Atom *anchor = target->atom(indexes[i]);
        if (anchor->isVisited()) continue; // т.к. нет детей - выходим тут

        if (anchor->is(21))
        {
            if (!anchor->hasRole(21, DIMER_CRs))
            {
                auto spec = new DimerCRs(indexes[i], DIMER_CRs, target);

#ifdef PRINT
                spec->wasFound();
#endif // PRINT

                anchor->describe(21, spec);
                spec->findChildren();
            }
        }
        else
        {
            auto spec = anchor->specificSpecByRole(21, DIMER_CRs);
            if (spec)
            {
                spec->removeReactions();

#ifdef PRINT
                spec->wasForgotten();
#endif // PRINT

                anchor->forget(21, spec);
                Handbook::scavenger.markSpec<DIMER_CRs>(spec);
            }
        }
    }
}

void DimerCRs::findChildren()
{
    AdsMethylToDimer::find(this);
}
