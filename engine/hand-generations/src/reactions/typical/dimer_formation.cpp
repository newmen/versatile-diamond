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

            create<DimerFormation>(targets);
        }
    });
}

void DimerFormation::doIt()
{
    assert(target(0)->type() == BridgeCTsi::ID);
    assert(target(1)->type() == BridgeCTsi::ID);

    Atom *atoms[2] = { target(0)->atom(0), target(1)->atom(0) };
    analyzeAndChangeAtoms(atoms, 2);
    Finder::findAll(atoms, 2);
}

void DimerFormation::changeAtoms(Atom **atoms)
{
    Atom *a = atoms[0], *b = atoms[1];

    a->bondWith(b);

    changeAtom(a);
    changeAtom(b);
}

LateralReaction *DimerFormation::lookAround()
{
    Atom *atoms[2] = { target(0)->atom(0), target(1)->atom(0) };
    LateralSpec *neighbours[2] = { nullptr, nullptr };
    LateralReaction *concreted = nullptr;

    Dimer::row(atoms, [this, &neighbours, &concreted](LateralSpec *spec) {
        if (neighbours[0])
        {
            neighbours[1] = spec;
            assert(concreted);
            delete concreted;
            concreted = new DimerFormationInMiddle(this, neighbours);
        }
        else
        {
            concreted = new DimerFormationAtEnd(this, spec);
            neighbours[0] = spec;
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
