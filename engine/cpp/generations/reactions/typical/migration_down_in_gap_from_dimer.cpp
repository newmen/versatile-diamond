#include "migration_down_in_gap_from_dimer.h"
#include "lookers/near_methyl_on_dimer.h"
#include "lookers/near_gap.h"
#include "lookers/near_part_of_gap.h"

void MigrationDownInGapFromDimer::find(BridgeCRs *target)
{
    NearPartOfGap::look(target, [target](SpecificSpec *neighbourBridge, Atom **anchors) {
        NearMethylOnDimer::look<MethylOnDimerCMssu>(
                    27, anchors, [target, neighbourBridge](SpecificSpec *other) {
            SpecificSpec *targets[3] = { other, target, neighbourBridge };
            create<MigrationDownInGapFromDimer>(targets);
        });
    });
}

void MigrationDownInGapFromDimer::find(MethylOnDimerCMssu *target)
{
    NearGap::look<MigrationDownInGapFromDimer>(target);
}

void MigrationDownInGapFromDimer::doIt()
{
    SpecificSpec *methylOnDimerCMssu = target(0);
    SpecificSpec *bridges[2] = { target(1), target(2) };
    assert(bridges[0] != bridges[1]);
    assert(bridges[0]->atom(1) != bridges[1]->atom(2));
    assert(bridges[0]->atom(2) != bridges[1]->atom(1));

    assert(methylOnDimerCMssu->type() == MethylOnDimerCMssu::ID);
    assert(bridges[0]->type() == BridgeCRs::ID);
    assert(bridges[1]->type() == BridgeCRs::ID);

    Atom *atoms[5] = {
        methylOnDimerCMssu->atom(4),
        methylOnDimerCMssu->atom(1),
        methylOnDimerCMssu->atom(0),
        bridges[0]->atom(1),
        bridges[1]->atom(1)
    };
    Atom *x = atoms[0], *z = atoms[1], *a = atoms[2], *b = atoms[3], *c = atoms[4];

    assert(x->is(22));
    assert(z->is(23));
    assert(a->is(27));
    assert(b->is(5));
    assert(c->is(5));

    x->unbondFrom(z);
    a->bondWith(b);
    a->bondWith(c);

    Handbook::amorph().erase(a);
    assert(b->lattice()->crystal() == c->lattice()->crystal());
    crystalBy(b)->insert(a, Diamond::front_110_at(b, c));

    if (x->is(21)) x->changeType(2);
    else if (x->is(20)) x->changeType(28);
    else if (x->is(23)) x->changeType(8);
    else
    {
        assert(x->is(32));
        x->changeType(5);
    }

    z->changeType(21);

    if (a->is(13)) a->changeType(21);
    else a->changeType(20);

    b->changeType(24);
    c->changeType(24);

    Finder::findAll(atoms, 5);
}
