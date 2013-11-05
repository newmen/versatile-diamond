#include "high_bridge_stand_to_one_bridge.h"
#include "../../handbook.h"

void HighBridgeStandToOneBridge::find(HighBridge *target)
{
    Atom *anchor = target->atom(1);

    assert(anchor->is(19));
    if (!anchor->prevIs(19))
    {
        assert(anchor->lattice());
        auto diamond = static_cast<const Diamond *>(anchor->lattice()->crystal());

        auto nbrs = diamond->front_100(anchor);
        // TODO: maybe need to parallel it?
        if (nbrs[0]) checkAndAdd(target, nbrs[0]);
        if (nbrs[1] && nbrs[1]->isVisited()) checkAndAdd(target, nbrs[1]);
    }
}

void HighBridgeStandToOneBridge::doIt()
{
    Atom *atoms[3] = { target(0)->atom(0), target(0)->atom(1), target(1)->atom(0) };
    Atom *a = atoms[0], *b = atoms[1], *c = atoms[2];

    a->unbondFrom(b);
    a->bondWith(c);

    Handbook::amorph.erase(a);

    assert(b->lattice()->crystal() == c->lattice()->crystal());
    auto diamond = static_cast<Diamond *>(b->lattice()->crystal());
    diamond->insert(a, DiamondRelations::front_110(b, c));

    assert(a->is(18));
    if (a->is(17)) a->changeType(2);
    else if (a->is(16)) a->changeType(1);
    else a->changeType(3);

    assert(b->is(19));
    b->changeType(5);

    assert(c->is(28));
    if (c->is(2)) c->changeType(5);
    else c->changeType(4);

    Finder::findAll(atoms, 3);
}

void HighBridgeStandToOneBridge::remove()
{
    Handbook::mc.remove<HIGH_BRIDGE_STAND_TO_ONE_BRIDGE>(this, false);
    Handbook::scavenger.markReaction<SCA_HIGH_BRIDGE_STAND_TO_ONE_BRIDGE>(this);
}

void HighBridgeStandToOneBridge::checkAndAdd(HighBridge *target, Atom *neighbour)
{
    if (neighbour->is(28))
    {
        assert(neighbour->hasRole(28, BRIDGE_CTsi));

        SpecificSpec *targets[2] = {
            target,
            neighbour->specificSpecByRole(28, BRIDGE_CTsi)
        };

        SpecReaction *reaction = new HighBridgeStandToOneBridge(targets);
        Handbook::mc.add<HIGH_BRIDGE_STAND_TO_ONE_BRIDGE>(reaction);

        for (int i = 0; i < 2; ++i)
        {
            targets[i]->usedIn(reaction);
        }
    }
}
