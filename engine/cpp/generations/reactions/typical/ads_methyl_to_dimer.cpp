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
        Handbook::mc.add<METHYL_TO_DIMER>(reaction);

        target->usedIn(reaction);
    }
}

void AdsMethylToDimer::doIt()
{
    Atom *a = target()->atom(0);
    assert(a->is(21));

    AtomBuilder builder;
    Atom *b = builder.buildC(25, 1);

    a->bondWith(b);
    a->changeType(23);

    Handbook::amorph.insert(b);
    Finder::findAll(&a, 1);
}

void AdsMethylToDimer::remove()
{
    Handbook::mc.remove<METHYL_TO_DIMER>(this);
}
