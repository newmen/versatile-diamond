#include "dimer_formation.h"
#include <omp.h>

#include <assert.h>

void DimerFormation::find(BridgeCTsi *target)
{
    const ushort indexes[1] = { 0 };
    const ushort types[1] = { 28 };

    ManyTypical::find<DimerFormation>(target, indexes, types, 1, 28, BRIDGE_CTsi, ManyTypical::front100Lambda);
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
