#include "dimer_formation.h"
#include <assert.h>
#include "../../species/sidepiece/dimer.h"
#include "../typical/dimer_formation.h"
#include "../lateral/dimer_formation_at_end.h"
#include "../lateral/dimer_formation_in_middle.h"

void DimerFormation::find(BridgeCTsi *target)
{
    Atom *anchor = target->anchor();
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

            createBy<DimerFormation>(targets);
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

LateralReaction *DimerFormation::findAllLateral()
{
    Atom *atoms[2] = { target(0)->atom(0), target(1)->atom(0) };
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
                    concreted = new DimerFormationInMiddle(this, neighbourSpecs);
                }
                else
                {
                    concreted = new DimerFormationAtEnd(this, lateralSpec);
                    neighbourSpecs[0] = lateralSpec;
                }
            }
        }
    });

    return concreted;
}

void DimerFormation::changeAtom(Atom *atom) const
{
    assert(atom->is(28));
    if (atom->is(2)) atom->changeType(21);
    else atom->changeType(20);
}
