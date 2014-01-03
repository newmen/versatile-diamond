#include "migration_down_at_dimer.h"
#include "lookers/near_methyl_on_bridge_cbi.h"
#include "lookers/near_activated_dimer.h"

void MigrationDownAtDimer::find(DimerCRs *target)
{
    Atom *atoms[2] = { target->atom(0), target->atom(3) };
    NearMethylOnBridgeCBi::look<MethylOnBridgeCBiCMsu>(26, atoms, [target](SpecificSpec *other) {
        SpecificSpec *targets[2] = { target, other };
        create<MigrationDownAtDimer>(targets);
    });
}

void MigrationDownAtDimer::find(MethylOnBridgeCBiCMsu *target)
{
    NearActivatedDimer::look<MigrationDownAtDimer>(target);
}

void MigrationDownAtDimer::doIt()
{
    SpecificSpec *dimerCRs = target(0);
    SpecificSpec *methylOnBridgeCBiCMsu = target(1);

    assert(dimerCRs->type() == DimerCRs::ID);
    assert(methylOnBridgeCBiCMsu->type() == MethylOnBridgeCBiCMsu::ID);

    Atom *atoms[4] = {
        methylOnBridgeCBiCMsu->atom(1),
        methylOnBridgeCBiCMsu->atom(0),
        dimerCRs->atom(0),
        dimerCRs->atom(3)
    };
    Atom *z = atoms[0], *a = atoms[1], *b = atoms[2], *c = atoms[3];

    assert(z->is(7));
    assert(a->is(26));
    assert(b->is(21));
    assert(c->is(22));

    bool hMigratedDown = false;
    if (a->type() == 26)
    {
        a->activate();
        b->deactivate();
        hMigratedDown = true;
    }

    b->unbondFrom(c);
    a->bondWith(b);
    a->bondWith(c);

    Handbook::amorph().erase(a);
    assert(b->lattice()->crystal() == c->lattice()->crystal());
    crystalBy(b)->insert(a, Diamond::front_110_at(b, c));

    if (z->is(8)) z->changeType(21);
    else z->changeType(20);

    if (a->is(13)) a->changeType(21);
    else if (a->is(27)) a->changeType(20);
    else
    {
        assert(a->type() == 26);
        a->changeType(20);
    }

    if (hMigratedDown) b->changeType(4);
    else b->changeType(5);

    if (c->is(32)) c->changeType(24);
    else if (c->is(21)) c->changeType(5);
    else if (c->is(20)) c->changeType(4);
    else
    {
        assert(c->type() == 23);
        c->changeType(33);
    }

    Finder::findAll(atoms, 4);
}
