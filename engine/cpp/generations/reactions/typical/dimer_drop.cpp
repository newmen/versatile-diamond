#include "dimer_drop.h"

#include <assert.h>

void DimerDrop::find(DimerCRiCLi *target)
{
    const ushort indexes[2] = { 0, 3 };
    const ushort types[2] = { 20, 20 };

    TargetAtoms ta(target, 2, indexes, types);
    MonoTypical::find<DimerDrop>(ta);
}

void DimerDrop::doIt()
{
    Atom *atoms[2] = { target()->atom(0), target()->atom(3) };
    Atom *a = atoms[0], *b = atoms[1];

    a->unbondFrom(b);

    changeAtom(a);
    changeAtom(b);

    Finder::findAll(atoms, 2);
}

void DimerDrop::changeAtom(Atom *atom) const
{
    assert(atom->is(20));
    if (atom->is(21)) atom->changeType(2);
    else atom->changeType(28);
}
