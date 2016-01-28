#include "migration_down_in_gap.h"
#include "lookers/near_methyl_on_bridge_cbi.h"
#include "lookers/near_gap.h"
#include "lookers/near_part_of_gap.h"

const char MigrationDownInGap::__name[] = "migration down in gap from methyl on bridge";

double MigrationDownInGap::RATE()
{
    static double value = getRate("MIGRATION_DOWN_IN_GAP");
    return value;
}

void MigrationDownInGap::find(BridgeCRs *target)
{
    NearPartOfGap::look(target, [target](SpecificSpec *neighbourBridge, Atom **anchors) {
        NearMethylOnBridgeCBi::look<MethylOnBridgeCBiCMssiu>(
                    27, anchors, [target, neighbourBridge](SpecificSpec *other) {
            SpecificSpec *targets[3] = { other, target, neighbourBridge };
            create<MigrationDownInGap>(targets);
        });
    });
}

void MigrationDownInGap::find(MethylOnBridgeCBiCMssiu *target)
{
    NearGap::look<MigrationDownInGap>(target);
}

void MigrationDownInGap::doIt()
{
    SpecificSpec *methylOnBridgeCBiCMssiu = target(0);
    SpecificSpec *bridges[2] = { target(1), target(2) };
    assert(bridges[0] != bridges[1]);
    assert(bridges[0]->atom(1) != bridges[1]->atom(2));
    assert(bridges[0]->atom(2) != bridges[1]->atom(1));

    assert(methylOnBridgeCBiCMssiu->type() == MethylOnBridgeCBiCMssiu::ID);
    assert(bridges[0]->type() == BridgeCRs::ID);
    assert(bridges[1]->type() == BridgeCRs::ID);

    Atom *atoms[4] = {
        methylOnBridgeCBiCMssiu->atom(1),
        methylOnBridgeCBiCMssiu->atom(0),
        bridges[0]->atom(1),
        bridges[1]->atom(1)
    };
    Atom *z = atoms[0], *a = atoms[1], *b = atoms[2], *c = atoms[3];

    assert(z->is(7));
    assert(a->is(27));
    assert(b->is(5));
    assert(c->is(5));

    Handbook::amorph().erase(a);
    crystalBy(b)->insert(a, Diamond::front_110_at({ b, c }));

    a->bondWith(b);
    a->bondWith(c);

    if (z->is(8)) z->changeType(21);
    else z->changeType(20);

    if (a->is(13)) a->changeType(21);
    else a->changeType(20);

    b->changeType(24);
    c->changeType(24);

    Finder::findAll(atoms, 4);
}
