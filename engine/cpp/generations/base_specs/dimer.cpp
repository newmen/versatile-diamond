#include "dimer.h"
#include "../handbook.h"
#include "../base_specs/methyl_on_dimer.h"
#include "../specific_specs/dimer_cri_cli.h"
#include "../specific_specs/dimer_crs.h"

#include <assert.h>

#ifdef PARALLEL
#include <omp.h>
#endif // PARALLEL

void Dimer::find(Atom *anchor)
{
    auto spec = specFromAtom(anchor);

    if (anchor->is(22))
    {
        if (spec)
        {
            spec->findChildren();
        }
        else
        {
            assert(anchor->lattice());
            auto diamond = static_cast<const Diamond *>(anchor->lattice()->crystal());

            auto nbrs = diamond->front_100(anchor);
            if (nbrs[0]) checkAndAdd(anchor, nbrs[0]);
            if (nbrs[1] && nbrs[1]->isVisited()) checkAndAdd(anchor, nbrs[1]);
        }
    }
    else
    {
        if (spec)
        {
            spec->findChildren();

#ifdef PRINT
            spec->wasForgotten();
#endif // PRINT

            anchor->forget(22, spec);
            spec->atom(anotherIndex(spec, anchor))->forget(22, spec);
            Handbook::scavenger.markSpec<DIMER>(spec);
        }
    }
}

void Dimer::findChildren()
{
#ifdef PARALLEL
#pragma omp parallel sections
    {
#pragma omp section
        {
#endif // PARALLEL
            MethylOnDimer::find(this);
#ifdef PARALLEL
        }
#pragma omp section
        {
#endif // PARALLEL
            DimerCRiCLi::find(this);
#ifdef PARALLEL
        }
#pragma omp section
        {
#endif // PARALLEL
            DimerCRs::find(this);
#ifdef PARALLEL
        }
    }
#endif // PARALLEL
}

void Dimer::checkAndAdd(Atom *anchor, Atom *neighbour)
{
    if (neighbour->is(22) && anchor->hasBondWith(neighbour))
    {
        assert(neighbour->hasRole(3, BRIDGE)); // may be need move to if condition
        assert(neighbour->lattice());

        BaseSpec *parents[2] = {
            anchor->specByRole(3, BRIDGE),
            neighbour->specByRole(3, BRIDGE)
        };
        auto spec = new Dimer(DIMER, parents);

#ifdef PRINT
        spec->wasFound();
#endif // PRINT

        anchor->describe(22, spec);
        neighbour->describe(22, spec);

        spec->findChildren();
    }
}

BaseSpec *Dimer::specFromAtom(Atom *anchor)
{
    auto spec = anchor->specByRole(22, DIMER);
    if (!spec) return nullptr;

    uint ai = anotherIndex(spec, anchor);
    Atom *another = spec->atom(ai);

    return (ai != 0 || another->isVisited()) ? spec : nullptr;
}

uint Dimer::anotherIndex(BaseSpec *spec, Atom *anchor)
{
    return (spec->atom(0) == anchor) ? 3 : 0;
}
