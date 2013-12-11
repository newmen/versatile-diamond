#include "dimer_formation.h"
#include <assert.h>

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

void DimerFormation::changeAtom(Atom *atom) const
{
    assert(atom->is(28));
    if (atom->is(2)) atom->changeType(21);
    else atom->changeType(20);
}
