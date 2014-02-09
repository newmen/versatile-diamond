#include "methyl_on_dimer_hydrogen_migration.h"
#include "../../handbook.h"

const char MethylOnDimerHydrogenMigration::__name[] = "methyl on dimer hydrogen migration";
const double MethylOnDimerHydrogenMigration::RATE = 2.1e12 * std::exp(-37.5e3 / (1.98 * Env::T));

void MethylOnDimerHydrogenMigration::find(MethylOnDimerCLsCMhiu *target)
{
    create<MethylOnDimerHydrogenMigration>(target);
}

void MethylOnDimerHydrogenMigration::doIt()
{
    assert(target()->type() == MethylOnDimerCLsCMhiu::ID);

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
