#include "ads_methyl_to_dimer.h"
#include "../../handbook.h"
#include "../../builders/atom_builder.h"

void AdsMethylToDimer::find(DimerCRs *target)
{
    Atom *anchor = target->atom(0);

    assert(anchor->is(21));
    if (!anchor->prevIs(21))
    {
        SpecReaction *reaction = new AdsMethylToDimer(target);
        Handbook::mc.add<ADS_METHYL_TO_DIMER>(reaction);

        target->usedIn(reaction);
    }
}

void AdsMethylToDimer::doIt()
{
    AtomBuilder builder;
    Atom *atoms[2] = { target()->atom(0), builder.buildC(25, 1) };
    Atom *a = atoms[0], *b = atoms[1];

    a->bondWith(b);

    assert(a->is(21));
    a->changeType(23);

    Handbook::amorph.insert(b);
    Finder::findAll(atoms, 2);
}

void AdsMethylToDimer::remove()
{
    Handbook::mc.remove<ADS_METHYL_TO_DIMER>(this);
}
