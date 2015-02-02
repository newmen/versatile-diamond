#include "dimer_formation.h"
#include "../../species/sidepiece/dimer.h"
#include "../lateral/dimer_formation_at_end.h"
#include "../lateral/dimer_formation_in_middle.h"

const char DimerFormation::__name[] = "dimer formation";

double DimerFormation::RATE()
{
    static double value = getRate("DIMER_FORMATION");
    return value;
}

void DimerFormation::find(BridgeCTsi *target)
{
    Atom *anchor = target->atom(0);
    assert(anchor->is(28));

    eachNeighbour(anchor, &Diamond::front_100, [target](Atom *neighbour) {
        // TODO: add checking that neighbour atom has not belongs to target spec?
        if (neighbour->is(28))
        {
            auto neighbourSpec = neighbour->specByRole<BridgeCTsi>(28);
            assert(neighbourSpec);

            SpecificSpec *targets[2] = {
                target,
                neighbourSpec
            };

            create<DimerFormation>(targets);
        }
    });
}

void DimerFormation::checkLaterals(Dimer *sidepiece)
{
    Atom *atoms[2] = { sidepiece->atom(0), sidepiece->atom(3) };
    eachNeighbours<2>(atoms, &Diamond::cross_100, [&](Atom **neighbours) {
        if (neighbours[0]->is(28) && neighbours[1]->is(28))
        {
            SpecificSpec *targets[2] = {
                neighbours[0]->specByRole<BridgeCTsi>(28),
                neighbours[1]->specByRole<BridgeCTsi>(28)
            };

            if (targets[0] && targets[1])
            {
                assert(targets[0] != targets[1]);
                {
                    auto neighbourReaction =
                            targets[0]->checkoutReactionWith<DimerFormationAtEnd>(targets[1]);
                    if (neighbourReaction)
                    {
                        if (!sidepiece->haveReaction(neighbourReaction))
                        {
                            neighbourReaction->concretize<DimerFormationInMiddle>(sidepiece);
                        }
                        return;
                    }
                }
                {
                    auto neighbourReaction =
                            targets[0]->checkoutReactionWith<DimerFormation>(targets[1]);
                    if (neighbourReaction)
                    {
                        neighbourReaction->concretize<DimerFormationAtEnd>(sidepiece);
                        return;
                    }
                }
            }
        }
    });
}

void DimerFormation::doIt()
{
    assert(target(0)->type() == BridgeCTsi::ID);
    assert(target(1)->type() == BridgeCTsi::ID);

    Atom *atoms[2] = { target(0)->atom(0), target(1)->atom(0) };
    Atom *a = atoms[0], *b = atoms[1];

    a->bondWith(b);

    changeAtom(a);
    changeAtom(b);

    Finder::findAll(atoms, 2);
}

bool DimerFormation::lookAround()
{
    bool result = false;
    LateralSpec *sidepieces[2] = { nullptr, nullptr };
    Atom *atoms[2] = { target(0)->atom(0), target(1)->atom(0) };
    eachNeighbours<2>(atoms, &Diamond::cross_100, [&](Atom **neighbours) {
        if (neighbours[0]->is(22) && neighbours[1]->is(22))
        {
            LateralSpec *oneSideSpecies[2] = {
                neighbours[0]->specByRole<Dimer>(22),
                neighbours[1]->specByRole<Dimer>(22)
            };

            if (oneSideSpecies[0] && oneSideSpecies[0] == oneSideSpecies[1])
            {
                if (sidepieces[0])
                {
                    sidepieces[1] = oneSideSpecies[0];
                }
                else
                {
                    sidepieces[0] = oneSideSpecies[0];
                    result = true;
                }
            }
        }
    });

    if (sidepieces[0] && sidepieces[1])
    {
        create<DimerFormationInMiddle>(this, sidepieces);
    }
    else if (sidepieces[0])
    {
        create<DimerFormationAtEnd>(this, sidepieces[0]);
    }

    return result;
}

void DimerFormation::changeAtom(Atom *atom) const
{
    assert(atom->is(28));
    if (atom->is(2)) atom->changeType(21);
    else atom->changeType(20);
}
