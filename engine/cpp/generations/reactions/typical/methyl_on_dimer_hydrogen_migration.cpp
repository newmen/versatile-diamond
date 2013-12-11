#include "methyl_on_dimer_hydrogen_migration.h"
#include "../../handbook.h"

#include <assert.h>

void MethylOnDimerHydrogenMigration::find(MethylOnDimerCLsCMu *target)
{
    createBy<MethylOnDimerHydrogenMigration>(target);
}

void MethylOnDimerHydrogenMigration::doIt()
{
    assert(target()->type() == MethylOnDimerCLsCMu::ID);

    Atom *atoms[3] = { target()->atom(0), target()->atom(4) };
    Atom *a = atoms[0], *b = atoms[1];

    assert(a->is(31));
    assert(!a->is(13));
    assert(b->is(21));

    a->activate();
    b->deactivate();

    if (a->is(30)) a->changeType(13);
    else if (a->is(29)) a->changeType(30);
    else a->changeType(29);

    b->changeType(20);

    Finder::findAll(atoms, 2);
}
