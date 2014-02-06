#include "migration_down_in_gap.h"
#include "lookers/near_methyl_on_bridge_cbi.h"
#include "lookers/near_gap.h"
#include "lookers/near_part_of_gap.h"

void MigrationDownInGap::find(BridgeCRs *target)
{
    NearPartOfGap::look(target, [target](SpecificSpec *neighbourBridge, Atom **anchors) {
        NearMethylOnBridgeCBi::look<MethylOnBridgeCBiCMssu>(
                    27, anchors, [target, neighbourBridge](SpecificSpec *other) {
            SpecificSpec *targets[3] = { other, target, neighbourBridge };
            create<MigrationDownInGap>(targets);
        });
    });
}

void MigrationDownInGap::find(MethylOnBridgeCBiCMssu *target)
{
    NearGap::look<MigrationDownInGap>(target);
}

void MigrationDownInGap::doIt()
{
    SpecificSpec *methylOnBridgeCBiCMssu = target(0);
    SpecificSpec *bridges[2] = { target(1), target(2) };
    assert(bridges[0] != bridges[1]);
    assert(bridges[0]->atom(1) != bridges[1]->atom(2));
    assert(bridges[0]->atom(2) != bridges[1]->atom(1));

    assert(methylOnBridgeCBiCMssu->type() == MethylOnBridgeCBiCMssu::ID);
    assert(bridges[0]->type() == BridgeCRs::ID);
    assert(bridges[1]->type() == BridgeCRs::ID);

    Atom *atoms[4] = {
        methylOnBridgeCBiCMssu->atom(1),
        methylOnBridgeCBiCMssu->atom(0),
        bridges[0]->atom(1),
        bridges[1]->atom(1)
    };
    Atom *z = atoms[0], *a = atoms[1], *b = atoms[2], *c = atoms[3];

    assert(z->is(7));
    assert(a->is(27));
    assert(b->is(5));
    assert(c->is(5));

    a->bondWith(b);
    a->bondWith(c);

    Handbook::amorph().erase(a);
    assert(b->lattice()->crystal() == c->lattice()->crystal());
    crystalBy(b)->insert(a, Diamond::front_110_at(b, c));

    if (z->is(8)) z->changeType(21);
    else z->changeType(20);

    if (a->is(13)) a->changeType(21);
    else a->changeType(20);

    b->changeType(24);
    c->changeType(24);

    Finder::findAll(atoms, 4);
}

const char *MigrationDownInGap::name() const
{
    static const char value[] = "migration down in gap from methyl on bridge";
    return value;
}
