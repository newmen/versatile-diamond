#include "dimer.h"
#include "../handbook.h"
#include "../specific_specs/dimer_cri_cli.h"

#include <assert.h>

#ifdef PRINT
#include <iostream>
#endif // PRINT

void Dimer::find(Atom *anchor)
{
    assert(anchor);

    if (anchor->is(22))
    {
        if (!anchor->prevIs(22) && anchor->hasRole(3, BRIDGE))
        {
            assert(anchor->lattice());

            auto diamond = dynamic_cast<const Diamond *>(anchor->lattice()->crystal());
            assert(diamond);

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
#ifdef PRINT
#pragma omp critical (print)
            std::cout << "  try forgotten DIMER " << " at [" << anchor << "]" << std::endl;
#endif // PRINT

            anchor->forget(22, DIMER);
            another->forget(22, DIMER);
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
    if (neighbour->is(22) && anchor->hasBondWith(neighbour) && neighbour->hasRole(3, BRIDGE))
    {
        assert(neighbour->lattice());

        BaseSpec *parents[2] = {
            anchor->specByRole(3, BRIDGE),
            neighbour->specByRole(3, BRIDGE)
        };
        auto spec = std::shared_ptr<BaseSpec>(new Dimer(DIMER, parents));

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
        auto spec = dynamic_cast<Dimer *>(anchor->specByRole(22, DIMER));
        uint ai = (spec->atom(0) == anchor) ? 3 : 0;
        Atom *another = spec->atom(ai);

        if (ai != 0 || another->isVisited())
        {
#ifdef PRINT
#pragma omp critical (print)
            std::cout << " << Found " << spec->name() << " ( " << anchor << " -- " << another << " ) with another index: "
                      << ai << " => '" << another->isVisited() << "'" << std::endl;
#endif // PRINT

            anchor->specByRole(22, DIMER)->findChildren();
            return another;
        }
    }
    return 0;
}

