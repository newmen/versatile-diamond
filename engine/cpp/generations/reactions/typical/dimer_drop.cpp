#include "dimer_drop.h"
#include "../../species/sidepiece/dimer.h"
#include "../lateral/dimer_drop_at_end.h"
#include "../lateral/dimer_drop_in_middle.h"

void DimerDrop::find(DimerCRiCLi *target)
{
    createBy<DimerDrop>(target);
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

LateralReaction *DimerDrop::findAllLateral()
{
    Atom *atoms[2] = { target()->atom(0), target()->atom(3) };
    LateralSpec *neighbourSpecs[2] = { nullptr, nullptr };
    LateralReaction *concreted = nullptr;

    eachNeighbours<2>(atoms, &Diamond::cross_100, [this, &neighbourSpecs, &concreted](Atom **neighbours) {
        if (neighbours[0]->is(22) && neighbours[1]->is(22))
        {
            LateralSpec *specsInNeighbour[2] = {
                neighbours[0]->specByRole<Dimer>(22),
                neighbours[1]->specByRole<Dimer>(22)
            };

            auto lateralSpec = specsInNeighbour[0];
            if (lateralSpec && specsInNeighbour[0] == specsInNeighbour[1])
            {
                if (neighbourSpecs[0])
                {
                    neighbourSpecs[1] = lateralSpec;
                    assert(concreted);
                    delete concreted;
                    concreted = new DimerDropInMiddle(this, neighbourSpecs);
                }
                else
                {
                    concreted = new DimerDropAtEnd(this, lateralSpec);
                    neighbourSpecs[0] = lateralSpec;
                }
            }
        }
    });

    return concreted;
}

void DimerDrop::changeAtom(Atom *atom) const
{
    assert(atom->is(20));
    if (atom->is(21)) atom->changeType(2);
    else atom->changeType(28);
}
