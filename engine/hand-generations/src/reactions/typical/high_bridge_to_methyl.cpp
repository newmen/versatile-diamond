#include "high_bridge_to_methyl.h"

const char HighBridgeToMethyl::__name[] = "high bridge to methyl";

double HighBridgeToMethyl::RATE()
{
    static double value = getRate("HIGH_BRIDGE_TO_METHYL");
    return value;
}

void HighBridgeToMethyl::find(HighBridge *target)
{
    Atom *anchor = target->anchor();
    eachNeighbour(anchor, &Diamond::front_100, [target](Atom *neighbour) {
        SpecificSpec *neighbourSpec = nullptr;
        if (neighbour->is(28))
        {
            neighbourSpec = neighbour->specByRole<BridgeCTsi>(28);
            assert(neighbourSpec);
        }
        else if (neighbour->is(5))
        {
            neighbourSpec = neighbour->specByRole<BridgeCRs>(5);
            assert(neighbourSpec);
        }

        if (neighbourSpec)
        {
            SpecificSpec *targets[2] = {
                target,
                neighbourSpec
            };

            create<HighBridgeToMethyl>(targets);
        }
    });
}

void HighBridgeToMethyl::find(BridgeCTsi *target)
{
    findByBridge(target);
}

void HighBridgeToMethyl::find(BridgeCRs *target)
{
    findByBridge(target);
}

void HighBridgeToMethyl::findByBridge(SpecificSpec *target)
{
    Atom *anchor = target->anchor();
    assert(anchor->is(5) || anchor->is(28));

    eachNeighbour(anchor, &Diamond::front_100, [target](Atom *neighbour) {
        if (neighbour->is(19))
        {
            auto neighbourSpec = neighbour->specByRole<HighBridge>(19);
            assert(neighbourSpec);

            SpecificSpec *targets[2] = {
                neighbourSpec,
                target
            };

            create<HighBridgeToMethyl>(targets);
        }
    });
}

void HighBridgeToMethyl::doIt()
{
    SpecificSpec *highBridge = target(0);
    SpecificSpec *bridgeCTs = target(1);

    assert(highBridge->type() == HighBridge::ID);
    assert(bridgeCTs->type() == BridgeCTsi::ID || bridgeCTs->type() == BridgeCRs::ID);

    Atom *atoms[3] = {
        highBridge->atom(0),
        highBridge->atom(1),
        bridgeCTs->atom((bridgeCTs->type() == BridgeCTsi::ID) ? 0 : 1)
    };
    analyzeAndChangeAtoms(atoms, 3);
    Finder::findAll(atoms, 3);
}

void HighBridgeToMethyl::changeAtoms(Atom **atoms)
{
    Atom *a = atoms[0], *b = atoms[1], *c = atoms[2];

    assert(a->is(18));
    assert(b->is(19));
    assert(c->is(5) || c->is(28));

    a->unbondFrom(b);
    b->bondWith(c);

    if (a->is(17)) a->changeType(13);
    else if (a->is(16)) a->changeType(27);
    else a->changeType(26);

    b->changeType(23);

    if (c->is(5)) c->changeType(32);
    else if (c->is(2)) c->changeType(21);
    else c->changeType(20);
}
