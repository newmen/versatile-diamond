#include "des_methyl_from_111.h"

const char DesMethylFrom111::__name[] = "desorption methyl from 111";
const double DesMethylFrom111::RATE = 5.4e6 * std::exp(-0 / (1.98 * Env::T));

void DesMethylFrom111::find(MethylOn111CMiu *target)
{
    create<DesMethylFrom111>(target);
}

void DesMethylFrom111::doIt()
{
    assert(target()->type() == MethylOn111CMiu::ID);

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
