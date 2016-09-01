#include "des_methyl_from_111.h"

const char DesMethylFrom111::__name[] = "desorption methyl from 111";

double DesMethylFrom111::RATE()
{
    static double value = getRate("DES_METHYL_FROM_111", Env::cH());
    return value;
}

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

    Handbook::amorph().erase(b);

    a->unbondFrom(b);

    a->changeType(5);

    Handbook::scavenger().markAtom(b);

    Finder::findAll(atoms, 2);
}
