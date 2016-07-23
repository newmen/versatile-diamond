#include "des_methyl_from_bridge.h"

const char DesMethylFromBridge::__name[] = "desorption methyl from bridge";

double DesMethylFromBridge::RATE()
{
    static double value = getRate("DES_METHYL_FROM_BRIDGE", Env::cH());
    return value;
}

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

    Handbook::amorph().erase(b);

    a->unbondFrom(b);

    if (a->is(8)) a->changeType(2);
    else a->changeType(28);

    b->prepareToRemove();
    Handbook::scavenger().markAtom(b);

    Finder::findAll(atoms, 2);
}
