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
                    auto neighbourReaction = targets[0]->checkoutReactionWith<DimerFormationAtEnd>(targets[1]);
                    if (neighbourReaction)
                    {
                        assert(!sidepiece->haveReaction(neighbourReaction));
                        SingleLateralReaction *chunk = new DimerFormationAtEnd(neighbourReaction->parent(), sidepiece);
                        neighbourReaction->concretize(chunk);
                        return;
                    }
                }
                {
                    auto neighbourReaction = targets[0]->checkoutReactionWith<DimerFormation>(targets[1]);
                    if (neighbourReaction)
                    {
                        SingleLateralReaction *chunk = new DimerFormationAtEnd(neighbourReaction, sidepiece);
                        neighbourReaction->concretize(chunk);
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

LateralReaction *DimerFormation::selectFrom(SingleLateralReaction **chunks, ushort num) const
{
    if (num == 2)
    {
        return new DimerFormationInMiddle(chunks);
    }
    else
    {
        assert(num == 1);
        return chunks[0];
    }
}

SpecReaction *DimerFormation::lookAround()
{
    uint index = 0;
    SingleLateralReaction * chunks[2] = { nullptr, nullptr };

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
                chunks[index++] = new DimerFormationAtEnd(this, oneSideSpecies[0]);
            }
        }
    });

    return selectReaction(chunks, index);
}

void DimerFormation::changeAtom(Atom *atom) const
{
    assert(atom->is(28));
    if (atom->is(2)) atom->changeType(21);
    else atom->changeType(20);
}
