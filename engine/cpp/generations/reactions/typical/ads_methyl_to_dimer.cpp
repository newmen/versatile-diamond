#include "ads_methyl_to_dimer.h"
#include "../../builders/atom_builder.h"

void AdsMethylToDimer::find(DimerCRs *target)
{
    createBy<AdsMethylToDimer>(target);
}

void AdsMethylToDimer::doIt()
{
    assert(target()->type() == DimerCRs::ID);

    AtomBuilder builder;
    Atom *atoms[2] = { target()->atom(0), builder.buildC(25, 1) };
    Atom *a = atoms[0], *b = atoms[1];
    Handbook::amorph().insert(b);

    assert(a->is(21));

    a->bondWith(b);

    a->changeType(23);

    Finder::findAll(atoms, 2);
}
