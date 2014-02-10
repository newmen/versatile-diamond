#include "ads_methyl_to_111.h"
#include "../../builders/atom_builder.h"

const char AdsMethylTo111::__name[] = "adsorption methyl to 111";
const double AdsMethylTo111::RATE = Env::cCH3 * 1.2e9 * std::exp(-0 / (1.98 * Env::T));

void AdsMethylTo111::find(BridgeCRs *target)
{
    create<AdsMethylTo111>(target);
}

void AdsMethylTo111::doIt()
{
    assert(target()->type() == BridgeCRs::ID);

    AtomBuilder builder;
    Atom *atoms[2] = { target()->atom(1), builder.buildC(25, 1) };
    Atom *a = atoms[0], *b = atoms[1];
    Handbook::amorph().insert(b);

    assert(a->is(5));

    a->bondWith(b);

    a->changeType(33);

    Finder::findAll(atoms, 2);
}
