#include "ads_methyl_to_111.h"

const char AdsMethylTo111::__name[] = "adsorption methyl to 111";

double AdsMethylTo111::RATE()
{
    static double value = getRate("ADS_METHYL_TO_111", Env::cCH3());
    return value;
}

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
    assert(a->is(5));

    Handbook::amorph().insert(b);

    a->bondWith(b);

    a->changeType(33);

    Finder::findAll(atoms, 2);
}
