#include "des_methyl_from_bridge.h"

const char DesMethylFromBridge::__name[] = "desorption methyl from bridge";
const double DesMethylFromBridge::RATE = 1.7e7 * std::exp(-0 / (1.98 * Env::T));

void DesMethylFromBridge::find(MethylOnBridgeCBiCMiu *target)
{
    create<DesMethylFromBridge>(target);
}

void DesMethylFromBridge::doIt()
{
    assert(target()->type() == MethylOnBridgeCBiCMiu::ID);

    Atom *atoms[2] = { target()->atom(1), target()->atom(0) };
    Atom *a = atoms[0], *b = atoms[1];

    assert(a->is(7));
    assert(b->is(25));

    a->unbondFrom(b);

    if (a->is(8)) a->changeType(2);
    else a->changeType(28);

    b->prepareToRemove();
    Handbook::amorph().erase(b);
    Handbook::scavenger().markAtom(b);

    Finder::findAll(atoms, 2);
}
