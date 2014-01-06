#include "migration_down_at_dimer_from_high_bridge.h"
#include "lookers/near_high_bridge.h"
#include "lookers/near_activated_dimer.h"

void MigrationDownAtDimerFromHighBridge::find(DimerCRs *target)
{
    Atom *atoms[2] = { target->atom(0), target->atom(3) };
    NearHighBridge::look<HighBridge>(18, atoms, [target](SpecificSpec *other) {
        SpecificSpec *targets[2] = { target, other };
        create<MigrationDownAtDimerFromHighBridge>(targets);
    });
}

void MigrationDownAtDimerFromHighBridge::find(HighBridge *target)
{
    NearActivatedDimer::look<MigrationDownAtDimerFromHighBridge>(target);
}

void MigrationDownAtDimerFromHighBridge::doIt()
{
    SpecificSpec *dimerCRs = target(0);
    SpecificSpec *highBridge = target(1);

    assert(dimerCRs->type() == DimerCRs::ID);
    assert(highBridge->type() == HighBridge::ID);

    Atom *atoms[4] = {
        highBridge->atom(1),
        highBridge->atom(0),
        dimerCRs->atom(0),
        dimerCRs->atom(3)
    };
    Atom *z = atoms[0], *a = atoms[1], *b = atoms[2], *c = atoms[3];

    assert(z->is(19));
    assert(a->is(18));
    assert(b->is(21));
    assert(c->is(22));

    bool hMigratedDown = false;
    if (a->type() == 18 || a->type() == 15)
    {
        a->activate();
        b->deactivate();
        hMigratedDown = true;
    }

    a->unbondFrom(z);
    b->unbondFrom(c);
    a->bondWith(b);
    a->bondWith(c);

    Handbook::amorph().erase(a);
    assert(b->lattice()->crystal() == c->lattice()->crystal());
    crystalBy(b)->insert(a, Diamond::front_110_at(b, c));

    z->changeType(21);

    if (a->is(17)) a->changeType(21);
//    else if (a->is(16)) a->changeType(20);
    else a->changeType(20);

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
