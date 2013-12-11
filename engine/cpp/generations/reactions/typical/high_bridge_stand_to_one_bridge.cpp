#include "high_bridge_stand_to_one_bridge.h"
#include <assert.h>

void HighBridgeStandToOneBridge::find(HighBridge *target)
{
    Atom *anchor = target->anchor();
    eachNeighbour(anchor, &Diamond::front_100, [target](Atom *neighbour) {
        if (neighbour->is(28))
        {
            auto neighbourSpec = neighbour->specByRole<BridgeCTsi>(28);
            assert(neighbourSpec);

            SpecificSpec *targets[2] = {
                target,
                neighbourSpec
            };

            createBy<HighBridgeStandToOneBridge>(targets);
        }
    });
}

void HighBridgeStandToOneBridge::find(BridgeCTsi *target)
{
    Atom *anchor = target->anchor();
    eachNeighbour(anchor, &Diamond::front_100, [target](Atom *neighbour) {
        if (neighbour->is(19))
        {
            auto neighbourSpec = neighbour->specByRole<HighBridge>(19);
            assert(neighbourSpec);

            SpecificSpec *targets[2] = {
                neighbourSpec,
                target
            };

            createBy<HighBridgeStandToOneBridge>(targets);
        }
    });
}

void HighBridgeStandToOneBridge::doIt()
{
    SpecificSpec *highBridge = target(0);
    SpecificSpec *bridgeCTsi = target(1);

    assert(highBridge->type() == HighBridge::ID);
    assert(bridgeCTsi->type() == BridgeCTsi::ID);

    Atom *atoms[3] = { highBridge->atom(0), highBridge->atom(1), bridgeCTsi->atom(0) };
    Atom *a = atoms[0], *b = atoms[1], *c = atoms[2];

    assert(a->is(18));
    assert(b->is(19));
    assert(c->is(28));

    a->unbondFrom(b);
    a->bondWith(c);

    Handbook::amorph().erase(a);
    assert(b->lattice()->crystal() == c->lattice()->crystal());
    crystalBy(b)->insert(a, Diamond::front_110(b, c));

    if (a->is(17)) a->changeType(2);
    else if (a->is(16)) a->changeType(1);
    else a->changeType(3);

    b->changeType(5);

    if (c->is(2)) c->changeType(5);
    else c->changeType(4);

    Finder::findAll(atoms, 3);
}
