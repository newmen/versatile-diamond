#include "dimer.h"
#include "../handbook.h"
#include "../specific_specs/dimer_cri_cli.h"

#include <assert.h>

void Dimer::find(Atom *anchor)
{
    assert(anchor);

    if (anchor->is(22))
    {
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
            checkAndFind(anchor);
        }
    }
    else
    {
        Atom *another = checkAndFind(anchor);
        if (another)
        {
            auto spec = anchor->specByRole(22, DIMER);
            anchor->forget(22, DIMER);
            another->forget(22, DIMER);
            Handbook::scavenger().storeSpec<DIMER>(spec);
        }
    }
}

void Dimer::findChildren()
{
    DimerCRiCLi::find(this);
}

void Dimer::checkAndAdd(Atom *anchor, Atom *neighbour)
{
    if (neighbour->is(22) && anchor->hasBondWith(neighbour) && neighbour->hasRole(3, BRIDGE))
    {
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

Atom *Dimer::checkAndFind(Atom *anchor)
{
    if (anchor->hasRole(22, DIMER))
    {
        auto spec = static_cast<SpecificSpec *>(anchor->specByRole(22, DIMER));
        uint ai = (spec->atom(0) == anchor) ? 3 : 0;
        Atom *another = spec->atom(ai);

        if (ai != 0 || another->isVisited())
        {
            anchor->specByRole(22, DIMER)->findChildren();
            return another;
        }
    }
    return 0;
}

