#include "bridge_with_dimer_to_high_bridge_and_dimer.h"

void BridgeWithDimerToHighBridgeAndDimer::find(BridgeWithDimerCBTiCBRsCDLi *target)
{
    create<BridgeWithDimerToHighBridgeAndDimer>(target);
}

void BridgeWithDimerToHighBridgeAndDimer::doIt()
{
    assert(target()->type() == BridgeWithDimerCBTiCBRsCDLi::ID);

    Atom *atoms[3] = { target()->atom(3), target()->atom(4), target()->atom(5) };
    Atom *a = atoms[0], *b = atoms[1], *c = atoms[2];

    assert(a->is(0));
    assert(b->is(5));
    assert(c->is(32));

    // erase from crystal should be before bond-unbond atoms
    a->lattice()->crystal()->erase(a);
    Handbook::amorph().insert(a);

    a->unbondFrom(c);
    a->bondWith(b);

    if (a->is(2)) a->changeType(17);
    else if (a->is(1)) a->changeType(16);
    else a->changeType(15);

    b->changeType(19);
    c->changeType(21);

    Finder::findAll(atoms, 3);
}

const char *BridgeWithDimerToHighBridgeAndDimer::name() const
{
    static const char value[] = "bridge with dimer to high bridge and dimer";
    return value;
}
