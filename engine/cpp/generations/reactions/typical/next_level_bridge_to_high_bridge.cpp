#include "next_level_bridge_to_high_bridge.h"

// TODO: must be used BridgeCRsCTi
void NextLevelBridgeToHighBridge::find(BridgeCRs *target)
{
    const ushort indexes[3] = { 0, 1, 2 };
    const ushort types[3] = { 0, 5, 4 };

    MonoTypical::find<NextLevelBridgeToHighBridge, 3>(target, indexes, types);
}

void NextLevelBridgeToHighBridge::doIt()
{
    Atom *atoms[3] = { target()->atom(0), target()->atom(1), target()->atom(2) };
    Atom *a = atoms[0], *b = atoms[1], *c = atoms[2];

    assert(a->is(0));
    assert(b->is(5));
    assert(c->is(4));

    a->lattice()->crystal()->erase(a);
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
