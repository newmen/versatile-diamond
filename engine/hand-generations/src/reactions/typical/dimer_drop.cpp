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

void DimerDrop::doIt()
{
    assert(target()->type() == DimerCRiCLi::ID);

    Atom *atoms[2] = { target()->atom(0), target()->atom(3) };
    analyzeAndChangeAtoms(atoms, 2);
    Finder::findAll(atoms, 2);
}

void DimerDrop::changeAtoms(Atom **atoms)
{
    Atom *a = atoms[0], *b = atoms[1];

    a->unbondFrom(b);

    changeAtom(a);
    changeAtom(b);
}

LateralReaction *DimerDrop::lookAround()
{
    Atom *atoms[2] = { target()->atom(0), target()->atom(3) };
    LateralSpec *neighbours[2] = { nullptr, nullptr };
    LateralReaction *concreted = nullptr;

    Dimer::row(atoms, [this, &neighbours, &concreted](LateralSpec *spec) {
        if (neighbours[0])
        {
            neighbours[1] = spec;
            assert(concreted);
            delete concreted;
            concreted = new DimerDropInMiddle(this, neighbours);
        }
        else
        {
            concreted = new DimerDropAtEnd(this, spec);
            neighbours[0] = spec;
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
