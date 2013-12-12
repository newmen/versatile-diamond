#include "dimer.h"
#include <assert.h>
#include "../../reactions/typical/dimer_formation.h"
#include "../../reactions/lateral/dimer_formation_at_end.h"
#include "../../reactions/lateral/dimer_formation_in_middle.h"
#include "../base/bridge.h"
#include "../base/methyl_on_dimer.h"
#include "../specific/bridge_ctsi.h"
#include "../specific/dimer_cri_cli.h"
#include "../specific/dimer_crs.h"

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
    Atom *atoms[2] = { atom(0), atom(3) };

    eachNeighbours<2>(atoms, &Diamond::cross_100, [this](Atom **neighbours) {
        if (neighbours[0]->is(28) && neighbours[1]->is(28))
        {
            SpecificSpec *specInNeighbour[2] = {
                neighbours[0]->specByRole<BridgeCTsi>(28),
                neighbours[1]->specByRole<BridgeCTsi>(28)
            };

            if (specInNeighbour[0] && specInNeighbour[1])
            {
                {
                    auto reaction = specInNeighbour[0]->reactionWith<DimerFormationAtEnd>(specInNeighbour[1]);
                    if (reaction)
                    {
                        if (reaction->haveLateral(this))
                        {
                            reaction->concretize<DimerFormationInMiddle>(this);
                        }
                        return;
                    }
                }
                {
                    auto reaction = specInNeighbour[0]->reactionWith<DimerFormation>(specInNeighbour[1]);
                    if (reaction)
                    {
                        reaction->concretize<DimerFormationAtEnd>(this);
                        return;
                    }
                }
            }
        }
    });

}
