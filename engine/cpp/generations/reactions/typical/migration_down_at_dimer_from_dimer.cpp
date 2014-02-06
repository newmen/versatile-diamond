#include "migration_down_at_dimer_from_dimer.h"
#include "lookers/near_methyl_on_dimer.h"
#include "lookers/near_activated_dimer.h"

void MigrationDownAtDimerFromDimer::find(DimerCRs *target)
{
    Atom *atoms[2] = { target->atom(0), target->atom(3) };
    NearMethylOnDimer::look<MethylOnDimerCMsu>(26, atoms, [target](SpecificSpec *other) {
        SpecificSpec *targets[2] = { target, other };
        create<MigrationDownAtDimerFromDimer>(targets);
    });
}

void MigrationDownAtDimerFromDimer::find(MethylOnDimerCMsu *target)
{
    NearActivatedDimer::look<MigrationDownAtDimerFromDimer>(target);
}

void MigrationDownAtDimerFromDimer::doIt()
{
    SpecificSpec *dimerCRs = target(0);
    SpecificSpec *methylOnDimerCMsu = target(1);

    assert(dimerCRs->type() == DimerCRs::ID);
    assert(methylOnDimerCMsu->type() == MethylOnDimerCMsu::ID);

    Atom *atoms[5] = {
        methylOnDimerCMsu->atom(4),
        methylOnDimerCMsu->atom(1),
        methylOnDimerCMsu->atom(0),
        dimerCRs->atom(0),
        dimerCRs->atom(3)
    };
    Atom *x = atoms[0], *z = atoms[1], *a = atoms[2], *b = atoms[3], *c = atoms[4];

    assert(x->is(22));
    assert(z->is(23));
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

    x->unbondFrom(z);
    b->unbondFrom(c);
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

    Finder::findAll(atoms, 5);
}

const char *MigrationDownAtDimerFromDimer::name() const
{
    static const char value[] = "migration down at activated dimer from methyl on dimer";
    return value;
}
