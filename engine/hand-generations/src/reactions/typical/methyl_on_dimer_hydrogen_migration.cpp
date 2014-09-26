#include "methyl_on_dimer_hydrogen_migration.h"
#include "../../handbook.h"

const char MethylOnDimerHydrogenMigration::__name[] = "methyl on dimer hydrogen migration";

double MethylOnDimerHydrogenMigration::RATE()
{
    static double value = getRate("METHYL_ON_DIMER_HYDROGEN_MIGRATION");
    return value;
}

void MethylOnDimerHydrogenMigration::find(MethylOnDimerCLsCMhiu *target)
{
    create<MethylOnDimerHydrogenMigration>(target);
}

void MethylOnDimerHydrogenMigration::doIt()
{
    assert(target()->type() == MethylOnDimerCLsCMhiu::ID);

    Atom *atoms[2] = { target()->atom(0), target()->atom(4) };
    analyzeAndChangeAtoms(atoms, 2);
    Finder::findAll(atoms, 2);
}

void MethylOnDimerHydrogenMigration::changeAtoms(Atom **atoms)
{
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
}
