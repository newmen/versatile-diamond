#include "des_methyl_from_dimer.h"

void DesMethylFromDimer::find(MethylOnDimerCMu *target)
{
    create<DesMethylFromDimer>(target);
}

void DesMethylFromDimer::doIt()
{
    assert(target()->type() == MethylOnDimerCMu::ID);

    Atom *atoms[2] = { target()->atom(1), target()->atom(0) };
    Atom *a = atoms[0], *b = atoms[1];

    assert(a->is(23));
    assert(b->is(25));

    a->unbondFrom(b);

    a->changeType(21);

    b->prepareToRemove();
    Handbook::amorph().erase(b);
    Handbook::scavenger().markAtom(b);

    Finder::findAll(atoms, 2);
}
