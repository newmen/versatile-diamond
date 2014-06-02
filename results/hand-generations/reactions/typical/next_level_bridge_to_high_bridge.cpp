#include "next_level_bridge_to_high_bridge.h"

const char NextLevelBridgeToHighBridge::__name[] = "next layer bridge to high bridge";

double NextLevelBridgeToHighBridge::RATE()
{
    static double value = getRate("NEXT_LEVEL_BRIDGE_TO_HIGH_BRIDGE");
    return value;
}

void NextLevelBridgeToHighBridge::find(BridgeCRsCTiCLi *target)
{
    create<NextLevelBridgeToHighBridge>(target);
}

void NextLevelBridgeToHighBridge::doIt()
{
    assert(target()->type() == BridgeCRsCTiCLi::ID);

    Atom *atoms[3] = { target()->atom(0), target()->atom(1), target()->atom(2) };
    Atom *a = atoms[0], *b = atoms[1], *c = atoms[2];

    assert(a->is(0));
    assert(b->is(5));
    assert(c->is(4));

    // erase from crystal should be before bond-unbond atoms
    a->lattice()->crystal()->erase(a);
    Handbook::amorph().insert(a);

    a->unbondFrom(c);
    a->bondWith(b);

    if (a->is(2)) a->changeType(17);
    else if (a->is(1)) a->changeType(16);
    else a->changeType(15);

    b->changeType(19);

    if (c->is(5)) c->changeType(2);
    else c->changeType(28);

    Finder::findAll(atoms, 3);
}
