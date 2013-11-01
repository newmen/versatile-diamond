#include "methyl_on_dimer.h"
#include "../handbook.h"

void MethylOnDimer::find(BaseSpec *target)
{
    uint indexes[2] = { 0, 3 };

    for (int i = 0; i < 2; ++i)
    {
        Atom *anchor = target->atom(indexes[i]);
        if (anchor->isVisited()) continue;

        if (anchor->is(23))
        {
            if (!anchor->prevIs(23))
            {
                Atom *methyl = anchor->amorphNeighbour();
                auto spec = new MethylOnDimer(&methyl, indexes[i], METHYL_ON_DIMER, &target);

#ifdef PRINT
                spec->wasFound();
#endif // PRINT

                anchor->describe(23, spec);
                methyl->describe(25, spec);
                spec->findChildren();
            }п
            else
            {
                auto spec = anchor->specByRole(23, METHYL_ON_DIMER);
                if (spec) spec->findChildren();
            }
        }
        else
        {
            if (anchor->prevIs(23))
            {
                auto spec = anchor->specByRole(23, METHYL_ON_DIMER);
                if (spec)
                {
                    spec->findChildren();

#ifdef PRINT
                    spec->wasForgotten();
#endif // PRINT

                    anchor->forget(23, spec);
                    spec->atom(0)->forget(25, spec);
                    Handbook::scavenger.markSpec<METHYL_ON_DIMER>(spec);
                }
            }
        }
    }
}

void MethylOnDimer::findChildren()
{
}
