#include "dimer.h"
#include "methyl_on_dimer.h"
#include "../specific/dimer_cri_cli.h"
#include "../specific/dimer_crs.h"

#include <assert.h>

ushort Dimer::__indexes[2] = { 0, 3 };
ushort Dimer::__roles[2] = { 22, 22 };

void Dimer::find(Atom *anchor)
{
    if (anchor->is(22))
    {
        if (!checkAndFind(anchor, 22, DIMER))
        {
            auto nbrs = diamondBy(anchor)->front_100(anchor);
            if (nbrs[0]) checkAndAdd(anchor, nbrs[0]);
            if (nbrs[1] && nbrs[1]->isVisited()) checkAndAdd(anchor, nbrs[1]);
        }
    }
}

void Dimer::findAllChildren()
{
    MethylOnDimer::find(this);
    DimerCRiCLi::find(this);
    DimerCRs::find(this);
}

void Dimer::checkAndAdd(Atom *anchor, Atom *neighbour)
{
    if (anchor->hasBondWith(neighbour) && neighbour->hasRole(3, BRIDGE))
    {
        assert(neighbour->is(22));
        assert(neighbour->lattice());

        BaseSpec *parents[2] = {
            anchor->specByRole(3, BRIDGE),
            neighbour->specByRole(3, BRIDGE)
        };

        createBy<Dimer>(parents);
    }
}
