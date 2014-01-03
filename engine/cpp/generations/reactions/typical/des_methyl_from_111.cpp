#include "des_methyl_from_111.h"

void DesMethylFrom111::find(MethylOn111CMu *target)
{
    create<DesMethylFrom111>(target);
}

void DesMethylFrom111::doIt()
{
    assert(target()->type() == MethylOn111CMu::ID);

    Atom *atoms[2] = { target()->atom(1), target()->atom(0) };
    Atom *a = atoms[0], *b = atoms[1];

    assert(a->is(33));
    assert(b->is(25));

    a->unbondFrom(b);

    a->changeType(5);

    b->prepareToRemove();
    Handbook::amorph().erase(b);
    Handbook::scavenger().markAtom(b);

    Finder::findAll(atoms, 2);
}
