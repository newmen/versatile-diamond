#include "des_methyl_from_bridge.h"

#include <assert.h>

void DesMethylFromBridge::find(MethylOnBridgeCBiCMu *target)
{
    createBy<DesMethylFromBridge>(target);
}

void DesMethylFromBridge::doIt()
{
    Atom *atoms[2] = { target()->atom(1) };
    Atom *a = atoms[0], *b = target()->atom(0);

    assert(a->is(7));

    a->unbondFrom(b);
    if (a->is(8)) a->changeType(2);
    else a->changeType(28);

    b->prepareToRemove();

    Handbook::amorph().erase(b);
    Handbook::scavenger().markAtom(b);

    Finder::findAll(atoms, 1);
}
