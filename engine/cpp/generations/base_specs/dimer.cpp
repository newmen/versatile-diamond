#include "dimer.h"
#include "../handbook.h"

#include <omp.h>

#include <assert.h>

void Dimer::find(BaseSpec *parent)
{
    assert(parent);

    Atom *anchor = parent->atom(0);
    assert(anchor);

    if (!anchor->is(22)) return;
    if (!anchor->prevIs(22))
    {
        assert(anchor->lattice());

        auto diamond = dynamic_cast<const Diamond *>(anchor->lattice()->crystal());
        assert(diamond);

        auto nbrs = diamond->front_100(anchor);
        if (nbrs[0] && nbrs[0]->is(22) && anchor->hasBondWith(nbrs[0]) && nbrs[0]->hasRole(3, BRIDGE))
        {
            BaseSpec *parents[2] = { parent, nbrs[0]->specByRole(3, BRIDGE) };
            auto dimer = std::shared_ptr<BaseSpec>(new Dimer(DIMER, parents));

            anchor->describe(22, dimer);
            nbrs[0]->describe(22, dimer);

            dimer->findChildren();
        }
        else return;
    }
}

void Dimer::findChildren()
{

}

