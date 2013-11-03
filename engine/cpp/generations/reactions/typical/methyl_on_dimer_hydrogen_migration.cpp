#include "methyl_on_dimer_hydrogen_migration.h"
#include "../../handbook.h"

#include <assert.h>

void MethylOnDimerHydrogenMigration::find(MethylOnDimerCLs *target)
{
    Atom *anchors[2] = { target->atom(0), target->atom(4) };

    assert(anchors[0]->is(25));
    assert(!anchors[0]->is(13));
    assert(anchors[1]->is(21));

    // TODO: не уверен по поводу ||, может быть надо &&
    if (!anchors[0]->prevIs(25) || !anchors[1]->prevIs(21))
    {
        SpecReaction *reaction = new MethylOnDimerHydrogenMigration(target);
        Handbook::mc.add<METHYL_ON_DIMER_HYDROGEN_MIGRATION>(reaction);

        target->usedIn(reaction);
    }
}

void MethylOnDimerHydrogenMigration::doIt()
{
    Atom *atoms[3] = { target()->atom(0), target()->atom(4) };
    Atom *a = atoms[0], *b = atoms[1];

    a->activate();
    b->deactivate();

    assert(a->is(25));
    assert(!a->is(13));
    if (a->is(12)) a->changeType(13);
    else if (a->is(11)) a->changeType(12);
    else if (a->is(14)) a->changeType(11);
    else assert(true);

    assert(b->is(21));
    b->changeType(20);

    Finder::findAll(atoms, 2);
}

void MethylOnDimerHydrogenMigration::remove()
{
    Handbook::mc.remove<METHYL_ON_DIMER_HYDROGEN_MIGRATION>(this);
}
