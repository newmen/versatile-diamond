#include "methyl_on_dimer.h"
#include "../handbook.h"
#include "../specific_specs/methyl_on_dimer_cls.h"
#include "../specific_specs/methyl_on_dimer_cms.h"

#include <omp.h>

void MethylOnDimer::find(Dimer *target)
{
    uint indexes[2] = { 0, 3 };

    for (int i = 0; i < 2; ++i)
    {
        Atom *anchor = target->atom(indexes[i]);
//        if (anchor->isVisited()) continue;

        if (anchor->is(23))
        {
            if (!anchor->isVisited() && !anchor->hasRole(23, METHYL_ON_DIMER))
            {
                Atom *methyl = anchor->amorphNeighbour();
                BaseSpec *parent = target;
                auto spec = new MethylOnDimer(&methyl, indexes[i], METHYL_ON_DIMER, &parent);

#ifdef PRINT
                spec->wasFound();
#endif // PRINT

                anchor->describe(23, spec);
                methyl->describe(25, spec);

                spec->findChildren();
            }
            else
            {
                auto spec = anchor->specByRole(23, METHYL_ON_DIMER);
                if (spec) spec->findChildren();
            }
        }
        else
        {
            if (anchor->hasRole(23, METHYL_ON_DIMER))
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
#ifdef PARALLEL
#pragma omp parallel sections
    {
#pragma omp section
        {
#endif // PARALLEL
            MethylOnDimerCLs::find(this);
#ifdef PARALLEL
        }
#pragma omp section
        {
#endif // PARALLEL
            MethylOnDimerCMs::find(this);
#ifdef PARALLEL
        }
    }
#endif // PARALLEL
}
