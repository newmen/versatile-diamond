#include "dimer_formation_near_bridge.h"

void DimerFormationNearBridge::find(BridgeCTsi *target)
{
    Atom *anchor = target->anchor();
    auto diamond = crystalBy<Diamond>(anchor);
    eachNeighbour(anchor, diamond, &Diamond::front_100, [target](Atom *neighbour) {
        if (neighbour->is(5))
        {
            auto neighbourSpec = neighbour->specificSpecByRole(5, BRIDGE_CRs);
            if (neighbourSpec)
            {
                SpecificSpec *targets[2] = {
                    target,
                    neighbourSpec
                };

                createBy<DimerFormationNearBridge>(targets);
            }
        }
    });
}

void DimerFormationNearBridge::find(BridgeCRs *target)
{
    Atom *anchor = target->anchor();
    auto diamond = crystalBy<Diamond>(anchor);
    eachNeighbour(anchor, diamond, &Diamond::front_100, [target](Atom *neighbour) {
        if (neighbour->is(28))
        {
            auto neighbourSpec = neighbour->specificSpecByRole(28, BRIDGE_CTsi);
            if (neighbourSpec)
            {
                SpecificSpec *targets[2] = {
                    neighbourSpec,
                    target
                };

                createBy<DimerFormationNearBridge>(targets);
            }
        }
    });
}

void DimerFormationNearBridge::doIt()
{
    assert(target(0)->type() == BRIDGE_CTsi);
    assert(target(1)->type() == BRIDGE_CRs);

    SpecificSpec *bridgeCTsi = target(0);
    SpecificSpec *bridgeCRs = target(1);

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
