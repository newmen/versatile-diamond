#include "ads_methyl_to_dimer.h"

const char AdsMethylToDimer::__name[] = "adsorption methyl to dimer";

double AdsMethylToDimer::RATE()
{
    static double value = getRate("ADS_METHYL_TO_DIMER", Env::cCH3());
    return value;
}

void AdsMethylToDimer::find(DimerCRs *target)
{
    create<AdsMethylToDimer>(target);
}

void AdsMethylToDimer::doIt()
{
    assert(target()->type() == DimerCRs::ID);

    AtomBuilder builder;
    Atom *atoms[2] = { target()->atom(0), builder.buildC(25, 1) };
    Atom *a = atoms[0], *b = atoms[1];
    assert(a->is(21));

    Handbook::amorph().insert(b);

    a->bondWith(b);

    a->changeType(23);

    Finder::findAll(atoms, 2);
}
