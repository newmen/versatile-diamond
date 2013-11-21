#include "high_bridge_to_two_bridges.h"

void HighBridgeToTwoBridges::find(HighBridge *target)
{
    ManyTypical::find<HighBridgeToTwoBridges>(target, 5, BRIDGE_CRs, front100Lambda);
}

void HighBridgeToTwoBridges::find(BridgeCRs *target)
{
    ManyTypical::find<HighBridgeToTwoBridges>(target, 19, HIGH_BRIDGE, front100Lambda);
}

void HighBridgeToTwoBridges::doIt()
{
    SpecificSpec *highBridge;
    SpecificSpec *bridgeCRs;
    if (target(0)->type() == HIGH_BRIDGE)
    {
        assert(target(1)->type() == BRIDGE_CRs);
        highBridge = target(0);
        bridgeCRs = target(1);
    }
    else
    {
        assert(target(0)->type() == BRIDGE_CRs);
        assert(target(1)->type() == HIGH_BRIDGE);
        highBridge = target(1);
        bridgeCRs = target(0);
    }

    Atom *atoms[3] = { highBridge->atom(0), highBridge->atom(1), bridgeCRs->atom(1) };
    Atom *a = atoms[0], *b = atoms[1], *c = atoms[2];

    assert(a->is(18));
    assert(b->is(19));
    assert(c->is(5));

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
    c->changeType(24);

    Finder::findAll(atoms, 3);
}
