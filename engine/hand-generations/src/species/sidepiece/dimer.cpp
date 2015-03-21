#include "dimer.h"
#include "../../reactions/typical/dimer_drop.h"
#include "../../reactions/typical/dimer_formation.h"
#include "../base/methyl_on_dimer.h"
#include "../specific/dimer_crs.h"
#include "../specific/dimer_cri_cli.h"

void Dimer::find(Atom *anchor)
{
    if (anchor->is(22))
    {
        if (!anchor->checkAndFind(DIMER, 22))
        {
            eachNeighbour(anchor, &Diamond::front_100, [anchor](Atom *neighbour) {
                if (neighbour->is(22) && anchor->hasBondWith(neighbour))
                {
                    assert(neighbour->hasRole(BRIDGE, 3));
                    assert(neighbour->lattice());

                    ParentSpec *parents[2] = {
                        anchor->specByRole<Bridge>(3),
                        neighbour->specByRole<Bridge>(3)
                    };

                    create<Dimer>(parents);
                }
            });
        }
    }
}

void Dimer::findAllChildren()
{
    DimerCRs::find(this);
    DimerCRiCLi::find(this);
}

void Dimer::findAllLateralReactions()
{
    DimerFormation::checkLaterals(this);
    DimerDrop::checkLaterals(this);
}
