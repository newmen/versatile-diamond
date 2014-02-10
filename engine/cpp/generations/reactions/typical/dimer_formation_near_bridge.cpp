#include "dimer_formation_near_bridge.h"

const char DimerFormationNearBridge::__name[] = "dimer formation near bridge";
const double DimerFormationNearBridge::RATE = 7.5e11 * std::exp(-4e3 / (1.98 * Env::T));

void DimerFormationNearBridge::find(BridgeCTsi *target)
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

            create<DimerFormationNearBridge>(targets);
        }
    });
}

void DimerFormationNearBridge::find(BridgeCRs *target)
{
    Atom *anchor = target->anchor();
    eachNeighbour(anchor, &Diamond::front_100, [target](Atom *neighbour) {
        if (neighbour->is(28))
        {
            auto neighbourSpec = neighbour->specByRole<BridgeCTsi>(28);
            assert(neighbourSpec);

            SpecificSpec *targets[2] = {
                neighbourSpec,
                target
            };

            create<DimerFormationNearBridge>(targets);
        }
    });
}

void DimerFormationNearBridge::doIt()
{
    SpecificSpec *bridgeCTsi = target(0);
    SpecificSpec *bridgeCRs = target(1);

    assert(bridgeCTsi->type() == BridgeCTsi::ID);
    assert(bridgeCRs->type() == BridgeCRs::ID);

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
