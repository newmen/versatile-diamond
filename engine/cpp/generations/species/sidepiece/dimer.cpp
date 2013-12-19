#include "dimer.h"
#include "../../reactions/lateral/dimer_drop_at_end.h"
#include "../../reactions/lateral/dimer_drop_in_middle.h"
#include "../../reactions/lateral/dimer_formation_at_end.h"
#include "../../reactions/lateral/dimer_formation_in_middle.h"
#include "../../reactions/typical/dimer_drop.h"
#include "../../reactions/typical/dimer_formation.h"
#include "../base/bridge.h"
#include "../base/methyl_on_dimer.h"
#include "../specific/bridge_ctsi.h"
#include "../specific/dimer_cri_cli.h"
#include "../specific/dimer_crs.h"

ushort Dimer::__indexes[2] = { 0, 3 };
ushort Dimer::__roles[2] = { 22, 22 };

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

                    ParentSpec *parents[2] = {
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
        DimerFormation::ifTargets(neighbours, [this](SpecificSpec **targets) {
            {
                auto neighbourReaction =
                        targets[0]->checkoutReactionWith<DimerFormationAtEnd>(targets[1]);
                if (neighbourReaction)
                {
                    if (!haveReaction(neighbourReaction))
                    {
                        neighbourReaction->concretize<DimerFormationInMiddle>(this);
                    }
                    return;
                }
            }
            {
                auto neighbourReaction =
                        targets[0]->checkoutReactionWith<DimerFormation>(targets[1]);
                if (neighbourReaction)
                {
                    neighbourReaction->concretize<DimerFormationAtEnd>(this);
                    return;
                }
            }
        });

        DimerDrop::ifTarget(neighbours, [this](SpecificSpec *target) {
            {
                auto neighbourReaction = target->checkoutReaction<DimerDropAtEnd>();
                if (neighbourReaction)
                {
                    if (!haveReaction(neighbourReaction))
                    {
                        neighbourReaction->concretize<DimerDropInMiddle>(this);
                    }
                    return;
                }
            }
            {
                auto neighbourReaction = target->checkoutReaction<DimerDrop>();
                if (neighbourReaction)
                {
                    neighbourReaction->concretize<DimerDropAtEnd>(this);
                    return;
                }
            }
        });
    });
}
