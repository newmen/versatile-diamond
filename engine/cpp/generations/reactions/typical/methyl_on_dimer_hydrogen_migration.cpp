#include "methyl_on_dimer_hydrogen_migration.h"
#include "../../handbook.h"

#include <assert.h>

void MethylOnDimerHydrogenMigration::find(MethylOnDimerCLsCMu *target)
{
    const ushort indexes[2] = { 0, 4 };
    const ushort types[2] = { 31, 21 };

    MonoTypical::find<MethylOnDimerHydrogenMigration, 2>(target, indexes, types);
}

void MethylOnDimerHydrogenMigration::doIt()
{
    Atom *atoms[3] = { target()->atom(0), target()->atom(4) };
    Atom *a = atoms[0], *b = atoms[1];

    a->activate();
    b->deactivate();

    assert(a->is(31));
    assert(!a->is(13));
    if (a->is(30)) a->changeType(13);
    else if (a->is(29)) a->changeType(30);
    else a->changeType(29);

    assert(b->is(21));
    b->changeType(20);

    Finder::findAll(atoms, 2);
}
