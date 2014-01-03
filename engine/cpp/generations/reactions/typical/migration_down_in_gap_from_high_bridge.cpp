#include "migration_down_in_gap_from_high_bridge.h"
#include "lookers/near_high_bridge.h"
#include "lookers/near_gap.h"
#include "lookers/near_part_of_gap.h"

void MigrationDownInGapFromHighBridge::find(BridgeCRs *target)
{
    NearPartOfGap::look(target, [target](SpecificSpec *neighbourBridge, Atom **anchors) {
        NearHighBridge::look<HighBridgeCMs>(
                    16, anchors, [target, neighbourBridge](SpecificSpec *other) {
            SpecificSpec *targets[3] = { other, target, neighbourBridge };
            create<MigrationDownInGapFromHighBridge>(targets);
        });
    });
}

void MigrationDownInGapFromHighBridge::find(HighBridgeCMs *target)
{
    NearGap::look<MigrationDownInGapFromHighBridge>(target);
}

void MigrationDownInGapFromHighBridge::doIt()
{
    SpecificSpec *highBridge = target(0);
    SpecificSpec *bridges[2] = { target(1), target(2) };
    assert(bridges[0] != bridges[1]);
    assert(bridges[0]->atom(1) != bridges[1]->atom(2));
    assert(bridges[0]->atom(2) != bridges[1]->atom(1));

    assert(highBridge->type() == HighBridgeCMs::ID);
    assert(bridges[0]->type() == BridgeCRs::ID);
    assert(bridges[1]->type() == BridgeCRs::ID);

    Atom *atoms[4] = {
        highBridge->atom(1),
        highBridge->atom(0),
        bridges[0]->atom(1),
        bridges[1]->atom(1)
    };
    Atom *z = atoms[0], *a = atoms[1], *b = atoms[2], *c = atoms[3];

    assert(z->is(19));
    assert(a->is(16));
    assert(b->is(5));
    assert(c->is(5));

    a->unbondFrom(z);
    a->bondWith(b);
    a->bondWith(c);

    Handbook::amorph().erase(a);
    assert(b->lattice()->crystal() == c->lattice()->crystal());
    crystalBy(b)->insert(a, Diamond::front_110_at(b, c));

    z->changeType(21);

    if (a->is(17)) a->changeType(21);
    else a->changeType(20);

    b->changeType(24);
    c->changeType(24);

    Finder::findAll(atoms, 4);
}
