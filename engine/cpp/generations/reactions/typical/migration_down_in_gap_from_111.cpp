#include "migration_down_in_gap_from_111.h"
#include "lookers/near_methyl_on_111.h"
#include "lookers/near_gap.h"
#include "lookers/near_part_of_gap.h"

const char MigrationDownInGapFrom111::__name[] = "migration down in gap from 111";
const double MigrationDownInGapFrom111::RATE = 5e12 * std::exp(-0 / (1.98 * Env::T)); // TODO: imagine

void MigrationDownInGapFrom111::find(BridgeCRs *target)
{
    NearPartOfGap::look(target, [target](SpecificSpec *neighbourBridge, Atom **anchors) {
        NearMethylOn111::look<MethylOn111CMssiu>(
                    27, anchors, [target, neighbourBridge](SpecificSpec *other) {
            SpecificSpec *targets[3] = { other, target, neighbourBridge };
            create<MigrationDownInGapFrom111>(targets);
        });
    });
}

void MigrationDownInGapFrom111::find(MethylOn111CMssiu *target)
{
    NearGap::look<MigrationDownInGapFrom111>(target);
}

void MigrationDownInGapFrom111::doIt()
{
    SpecificSpec *methylOn111CMssiu = target(0);
    SpecificSpec *bridges[2] = { target(1), target(2) };
    assert(bridges[0] != bridges[1]);
    assert(bridges[0]->atom(1) != bridges[1]->atom(2));
    assert(bridges[0]->atom(2) != bridges[1]->atom(1));

    assert(methylOn111CMssiu->type() == MethylOn111CMssiu::ID);
    assert(bridges[0]->type() == BridgeCRs::ID);
    assert(bridges[1]->type() == BridgeCRs::ID);

    Atom *atoms[4] = {
        methylOn111CMssiu->atom(1),
        methylOn111CMssiu->atom(0),
        bridges[0]->atom(1),
        bridges[1]->atom(1)
    };
    Atom *z = atoms[0], *a = atoms[1], *b = atoms[2], *c = atoms[3];

    assert(z->is(33));
    assert(a->is(27));
    assert(b->is(5));
    assert(c->is(5));

    a->bondWith(b);
    a->bondWith(c);

    Handbook::amorph().erase(a);
    assert(b->lattice()->crystal() == c->lattice()->crystal());
    crystalBy(b)->insert(a, Diamond::front_110_at(b, c));

    z->changeType(24);

    if (a->is(13)) a->changeType(21);
    else a->changeType(20);

    b->changeType(24);
    c->changeType(24);

    Finder::findAll(atoms, 4);
}
