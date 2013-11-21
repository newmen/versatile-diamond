#include "high_bridge_stand_to_one_bridge.h"

#include <assert.h>

void HighBridgeStandToOneBridge::find(HighBridge *target)
{
    ManyTypical::find<HighBridgeStandToOneBridge>(target, 28, BRIDGE_CTsi, front100Lambda);
}

void HighBridgeStandToOneBridge::find(BridgeCTsi *target)
{
    ManyTypical::find<HighBridgeStandToOneBridge>(target, 19, HIGH_BRIDGE, front100Lambda);
}

void HighBridgeStandToOneBridge::doIt()
{
    SpecificSpec *highBridge;
    SpecificSpec *bridgeCTsi;
    if (target(0)->type() == HIGH_BRIDGE)
    {
        assert(target(1)->type() == BRIDGE_CTsi);
        highBridge = target(0);
        bridgeCTsi = target(1);
    }
    else
    {
        assert(target(0)->type() == BRIDGE_CTsi);
        assert(target(1)->type() == HIGH_BRIDGE);
        highBridge = target(1);
        bridgeCTsi = target(0);
    }

    Atom *atoms[3] = { highBridge->atom(0), highBridge->atom(1), bridgeCTsi->atom(0) };
    Atom *a = atoms[0], *b = atoms[1], *c = atoms[2];

    assert(a->is(18));
    assert(b->is(19));
    assert(c->is(28));

    a->unbondFrom(b);
    a->bondWith(c);

    Handbook::amorph().erase(a);

    assert(b->lattice()->crystal() == c->lattice()->crystal());
    auto diamond = static_cast<Diamond *>(b->lattice()->crystal());
    diamond->insert(a, DiamondRelations::front_110(b, c));

    if (a->is(17)) a->changeType(2);
    else if (a->is(16)) a->changeType(1);
    else a->changeType(3);

    b->changeType(5);

    if (c->is(2)) c->changeType(5);
    else c->changeType(4);

    Finder::findAll(atoms, 3);
}
