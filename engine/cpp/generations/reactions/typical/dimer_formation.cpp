#include "dimer_formation.h"
#include <assert.h>

void DimerFormation::find(BridgeCTsi *target)
{
    Atom *anchor = target->anchor();
    auto diamond = crystalBy<Diamond>(anchor);
    eachNeighbour(anchor, diamond, &Diamond::front_100, [target, diamond](Atom *neighbour) {
        // TODO: add checking that neighbour atom has not belongs to target spec?
        if (neighbour->is(28))
        {
            auto neighbourSpec = neighbour->specificSpecByRole(28, BRIDGE_CTsi);
            if (neighbourSpec)
            {
                SpecificSpec *targets[2] = {
                    target,
                    neighbourSpec
                };

                auto reaction = createBy<DimerFormation>(targets); // !!! store

                Atom *atoms[2] = {
                    target->atom(0),
                    neighbourSpec->atom(0)
                };

                eachNeighbours<2>(atoms, diamond, &Diamond::cross_100, [reaction](Atom **neighbours) {
                    if (neighbours[0]->is(22) && neighbours[1]->is(22))
                    {
                        BaseSpec *neighbourSpecs[2] = {
                            neighbours[0]->specByRole(22, DIMER),
                            neighbours[1]->specByRole(22, DIMER)
                        };

                        if (neighbourSpecs[0] == neighbourSpecs[1])
                        {
                            assert(true);
//                            reaction = reaction->concretize(neighbourSpecs[0]);
                        }
                    }
                });
            }
        }
    });
}

void DimerFormation::doIt()
{
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
