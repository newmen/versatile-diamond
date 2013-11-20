#include "dimer_formation_near_bridge.h"

void DimerFormationNearBridge::find(BridgeCTsi *target)
{
    ManyTypical::find<DimerFormationNearBridge>(target, target->atom(0), 5, BRIDGE_CRs, front100Lambda);
}

void DimerFormationNearBridge::find(BridgeCRs *target)
{
    ManyTypical::find<DimerFormationNearBridge>(target, target->atom(1), 28, BRIDGE_CTsi, front100Lambda);
}

void DimerFormationNearBridge::doIt()
{
    SpecificSpec *bridgeCTsi;
    SpecificSpec *bridgeCRs;
    if (target(0)->type() == BRIDGE_CRs)
    {
        assert(target(1)->type() == BRIDGE_CTsi);
        bridgeCRs = target(0);
        bridgeCTsi = target(1);
    }
    else
    {
        assert(target(0)->type() == BRIDGE_CTsi);
        assert(target(1)->type() == BRIDGE_CRs);
        bridgeCRs = target(1);
        bridgeCTsi = target(0);
    }

    Atom *atoms[2] = { bridgeCTsi->atom(0), bridgeCRs->atom(1) };
    Atom *a = atoms[0], *b = atoms[1];

    assert(a->is(28));
    assert(b->is(5));

    a->bondWith(b);

    if (a->is(2)) a->changeType(21);
    else a->changeType(20);

    b->changeType(32);

    Finder::findAll(atoms, 2);
}
