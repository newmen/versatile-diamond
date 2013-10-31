#include "dimer.h"
#include "../handbook.h"
#include "../specific_specs/dimer_cri_cli.h"

#include <assert.h>

#ifdef PARALLEL
#include <omp.h>
#endif // PARALLEL

void Dimer::find(Atom *anchor)
{
    if (anchor->is(22))
    {
        assert(anchor->hasRole(3, BRIDGE));
        if (!anchor->prevIs(22))
        {
            assert(anchor->lattice());
            auto diamond = static_cast<const Diamond *>(anchor->lattice()->crystal());

            auto nbrs = diamond->front_100(anchor);
            if (nbrs[0]) checkAndAdd(anchor, nbrs[0]);
            if (nbrs[1] && nbrs[1]->isVisited()) checkAndAdd(anchor, nbrs[1]);
        }
        else
        {
            auto spec = specFromAtom(anchor);
            if (spec) spec->findChildren();
        }
    }
    else
    {
        if (anchor->prevIs(22))
        {
            auto spec = specFromAtom(anchor);
            if (spec)
            {
                spec->findChildren();

                auto spec = anchor->specByRole(22, DIMER);
                anchor->forget(22, spec);
                spec->atom(anotherIndex(spec, anchor))->forget(22, spec);
                Handbook::scavenger().storeSpec<DIMER>(spec);
            }
        }
    }
}

Dimer::Dimer(ushort type, BaseSpec **parents) : DependentSpec<2>(type, parents)
{
}

void Dimer::findChildren()
{
    DimerCRiCLi::find(this);
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
