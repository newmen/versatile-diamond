#include "high_bridge_to_two_bridges.h"

void HighBridgeToTwoBridges::find(HighBridge *target)
{
    Atom *anchor = target->anchor();
    eachNeighbour(anchor, &Diamond::front_100, [target](Atom *neighbour) {
        if (neighbour->is(5))
        {
            auto neighbourSpec = neighbour->specByRole<BridgeCRs>(5);
            assert(neighbourSpec);

            SpecificSpec *targets[2] = {
                target,
                neighbourSpec
            };

            createBy<HighBridgeToTwoBridges>(targets);
        }
    });
}

void HighBridgeToTwoBridges::find(BridgeCRs *target)
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

            createBy<HighBridgeToTwoBridges>(targets);
        }
    });
}

void HighBridgeToTwoBridges::doIt()
{
    SpecificSpec *highBridge = target(0);
    SpecificSpec *bridgeCRs = target(1);

    assert(highBridge->type() == HighBridge::ID);
    assert(bridgeCRs->type() == BridgeCRs::ID);

    Atom *atoms[3] = { highBridge->atom(0), highBridge->atom(1), bridgeCRs->atom(1) };
    Atom *a = atoms[0], *b = atoms[1], *c = atoms[2];

    assert(a->is(18));
    assert(b->is(19));
    assert(c->is(5));

    a->unbondFrom(b);
    a->bondWith(c);

    Handbook::amorph().erase(a);
    assert(b->lattice()->crystal() == c->lattice()->crystal());
    crystalBy(b)->insert(a, Diamond::front_110(b, c));

    if (a->is(17)) a->changeType(2);
    else if (a->is(16)) a->changeType(1);
    else a->changeType(3);

    b->changeType(5);
    c->changeType(24);

    Finder::findAll(atoms, 3);
}
