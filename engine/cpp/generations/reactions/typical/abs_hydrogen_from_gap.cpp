#include "abs_hydrogen_from_gap.h"

void AbsHydrogenFromGap::find(BridgeCRh *target)
{
    Atom *anchor = target->anchor();
    eachNeighbour(anchor, &Diamond::front_100, [target](Atom *neighbour) {
        if (neighbour->is(34) && target->atom(2) != neighbour)
        {
            auto neighbourSpec = neighbour->specByRole<BridgeCRh>(34);
            assert(neighbourSpec);

            SpecificSpec *targets[2] = {
                target,
                neighbourSpec
            };

            create<AbsHydrogenFromGap>(targets);
        }
    });
}

void AbsHydrogenFromGap::doIt()
{
    assert(target(0)->type() == BridgeCRh::ID);
    assert(target(1)->type() == BridgeCRh::ID);

    Atom *atoms[2] = { target(0)->atom(1), target(1)->atom(1) };
    Atom *a = atoms[0], *b = atoms[1];

    assert(a->lattice()->crystal() == b->lattice()->crystal());
    assert(!crystalBy(a)->atom(Diamond::front_110_at(a, b)));

    changeAtom(a);
    changeAtom(b);

    Finder::findAll(atoms, 2);
}

void AbsHydrogenFromGap::changeAtom(Atom *atom) const
{
    assert(atom->is(34));
    atom->activate();
    atom->changeType(5);
}
