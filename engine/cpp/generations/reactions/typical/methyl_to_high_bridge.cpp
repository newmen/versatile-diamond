#include "methyl_to_high_bridge.h"
#include "../../handbook.h"

#include <assert.h>

void MethylToHighBridge::find(MethylOnDimerCMsu *target)
{
    Atom *anchor = target->atom(0);

    assert(anchor->is(29));
    if (!anchor->prevIs(29))
    {
        SpecReaction *reaction = new MethylToHighBridge(target);
        Handbook::mc.add<METHYL_TO_HIGH_BRIDGE>(reaction);

        target->usedIn(reaction);
    }
}

void MethylToHighBridge::doIt()
{
    Atom *atoms[3] = { target()->atom(0), target()->atom(1), target()->atom(4) };
    Atom *a = atoms[0], *b = atoms[1], *c = atoms[2];

    b->unbondFrom(c);
    b->bondWith(a);

    assert(a->is(29));
    if (a->is(13)) a->changeType(17);
    else if (a->is(30)) a->changeType(16);
    else if (a->is(29)) a->changeType(18);
    else assert(true);

    assert(b->type() == 23);
    b->changeType(19);

    assert(c->is(22));
    if (c->is(21)) c->changeType(2);
    else if (c->is(23)) c->changeType(8);
    else if (c->is(22)) c->changeType(1);
    else assert(true);

    Finder::findAll(atoms, 3);
}

void MethylToHighBridge::remove()
{
    Handbook::mc.remove<METHYL_TO_HIGH_BRIDGE>(this);
}
