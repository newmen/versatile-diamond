#include "dimer_drop.h"
#include "../../species/sidepiece/dimer.h"
#include "../lateral/dimer_drop_at_end.h"
#include "../lateral/dimer_drop_in_middle.h"

const char DimerDrop::__name[] = "dimer drop";

double DimerDrop::RATE()
{
    static double value = getRate("DIMER_DROP");
    return value;
}

void DimerDrop::find(DimerCRiCLi *target)
{
    create<DimerDrop>(target);
}

void DimerDrop::checkLaterals(Dimer *sidepiece)
{
    Atom *atoms[2] = { sidepiece->atom(0), sidepiece->atom(3) };
    eachNeighbours<2>(atoms, &Diamond::cross_100, [&](Atom **neighbours) {
        if (neighbours[0]->is(20) && neighbours[1]->is(20))
        {
            SpecificSpec *targets[2] = {
                neighbours[0]->specByRole<DimerCRiCLi>(20),
                neighbours[1]->specByRole<DimerCRiCLi>(20)
            };

            if (targets[0] && targets[0] == targets[1])
            {
                SpecificSpec *target = targets[0];
                {
                    auto neighbourReaction = target->checkoutReaction<DimerDropAtEnd>();
                    if (neighbourReaction)
                    {
                        if (!sidepiece->haveReaction(neighbourReaction))
                        {
                            neighbourReaction->concretize<DimerDropInMiddle>(sidepiece);
                        }
                        return;
                    }
                }
                {
                    auto neighbourReaction = target->checkoutReaction<DimerDrop>();
                    if (neighbourReaction)
                    {
                        neighbourReaction->concretize<DimerDropAtEnd>(sidepiece);
                        return;
                    }
                }
            }
        }
    });
}

void DimerDrop::doIt()
{
    assert(target()->type() == DimerCRiCLi::ID);

    Atom *atoms[2] = { target()->atom(0), target()->atom(3) };
    Atom *a = atoms[0], *b = atoms[1];

    a->unbondFrom(b);

    changeAtom(a);
    changeAtom(b);

    Finder::findAll(atoms, 2);
}

bool DimerDrop::lookAround()
{
    bool result = false;
    LateralSpec *sidepieces[2] = { nullptr, nullptr };
    Atom *atoms[2] = { target()->atom(0), target()->atom(3) };
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
        create<DimerDropInMiddle>(this, sidepieces);
    }
    else if (sidepieces[0])
    {
        create<DimerDropAtEnd>(this, sidepieces[0]);
    }

    return result;
}

void DimerDrop::changeAtom(Atom *atom) const
{
    assert(atom->is(20));
    if (atom->is(21)) atom->changeType(2);
    else atom->changeType(28);
}
