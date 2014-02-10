#include "des_methyl_from_dimer.h"

const char DesMethylFromDimer::__name[] = "desorption methyl from dimer";
const double DesMethylFromDimer::RATE = 5.3e3 * std::exp(-0 / (1.98 * Env::T));

void DesMethylFromDimer::find(MethylOnDimerCMiu *target)
{
    create<DesMethylFromDimer>(target);
}

void DesMethylFromDimer::doIt()
{
    assert(target()->type() == MethylOnDimerCMiu::ID);

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
