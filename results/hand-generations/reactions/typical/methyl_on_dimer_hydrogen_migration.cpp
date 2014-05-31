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

    assert(a->is(35));
    assert(!a->is(13));
    assert(b->is(21));

    a->activate();
    b->deactivate();

    if (a->is(27)) a->changeType(13);
    else if (a->is(26)) a->changeType(27);
    else a->changeType(26);

    b->changeType(20);

    Finder::findAll(atoms, 2);
}
