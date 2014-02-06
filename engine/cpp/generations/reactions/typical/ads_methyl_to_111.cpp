#include "ads_methyl_to_111.h"
#include "../../builders/atom_builder.h"

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

const char *AdsMethylTo111::name() const
{
    static const char value[] = "adsorption methyl to 111";
    return value;
}
