#include "methyl_on_dimer_cmu.h"
#include "../handbook.h"
#include "methyl_on_dimer_cmsu.h"
#include "methyl_on_dimer_cls_cmu.h"

void MethylOnDimerCMu::find(MethylOnDimer *parent)
{
    Atom *anchor = parent->atom(0);

    if (anchor->is(31) && !anchor->is(13))
    {
        if (!anchor->hasRole(31, METHYL_ON_DIMER_CMu))
        {
            auto spec = new MethylOnDimerCMu(METHYL_ON_DIMER_CMu, parent);

#ifdef PRINT
            spec->wasFound();
#endif // PRINT

            anchor->describe(31, spec);
            spec->findChildren();
        }
        else
        {
            auto spec = anchor->specificSpecByRole(31, METHYL_ON_DIMER_CMu);
            if (spec) spec->findChildren();
        }
    }
    else
    {
        if (anchor->hasRole(31, METHYL_ON_DIMER_CMu))
        {
            auto spec = anchor->specificSpecByRole(31, METHYL_ON_DIMER_CMu);
            spec->findChildren();
            spec->removeReactions();

#ifdef PRINT
            spec->wasForgotten();
#endif // PRINT

            anchor->forget(31, spec);
            Handbook::scavenger.markSpec<METHYL_ON_DIMER_CMu>(spec);
        }
    }
}

void MethylOnDimerCMu::findChildren()
{
#ifdef PARALLEL
#pragma omp parallel sections
    {
#pragma omp section
        {
#endif // PARALLEL
            MethylOnDimerCLsCMu::find(this);
#ifdef PARALLEL
        }
#pragma omp section
        {
#endif // PARALLEL
            MethylOnDimerCMsu::find(this);
#ifdef PARALLEL
        }
    }
#endif // PARALLEL
}
