#include "dimer_drop_near_bridge.h"

void DimerDropNearBridge::find(BridgeWithDimerCDLi *target)
{
    create<DimerDropNearBridge>(target);
}

void DimerDropNearBridge::doIt()
{
    assert(target()->type() == BridgeWithDimerCDLi::ID);

    Atom *atoms[2] = { target()->atom(6), atoms[1] = target()->atom(9) };
    Atom *a = atoms[0], *b = atoms[1];

    assert(a->is(32));
    assert(b->is(20));

    a->unbondFrom(b);

    a->changeType(5);

    if (b->is(21)) b->changeType(2);
    else b->changeType(28);

    Finder::findAll(atoms, 2);
}

const char *DimerDropNearBridge::name() const
{
    static const char value[] = "dimer drop near bridge";
    return value;
}
