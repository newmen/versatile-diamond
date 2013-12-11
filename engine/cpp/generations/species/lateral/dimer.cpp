#include "dimer.h"
#include <assert.h>
#include "../base/bridge.h"
#include "../base/methyl_on_dimer.h"
#include "../specific/dimer_cri_cli.h"
#include "../specific/dimer_crs.h"
#include "../lateral/dimer.h"

void Dimer::find(Atom *anchor)
{
    if (anchor->is(22))
    {
        if (!checkAndFind<Dimer>(anchor, 22))
        {
            eachNeighbour(anchor, &Diamond::front_100, [anchor](Atom *neighbour) {
                if (anchor->hasBondWith(neighbour))
                {
                    assert(neighbour->hasRole<Bridge>(3));
                    assert(neighbour->is(22));
                    assert(neighbour->lattice());

                    BaseSpec *parents[2] = {
                        anchor->specByRole<Bridge>(3),
                        neighbour->specByRole<Bridge>(3)
                    };

                    createBy<Dimer>(parents);
                }
            });
        }
    }
}

void Dimer::findAllChildren()
{
    MethylOnDimer::find(this);
    DimerCRiCLi::find(this);
    DimerCRs::find(this);
}


void Dimer::findAllReactions()
{
}
