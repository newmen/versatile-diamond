#include "methyl_to_high_bridge.h"

#include <assert.h>

void MethylToHighBridge::find(MethylOnDimerCMsu *target)
{
    const ushort indexes[1] = { 0 };
    const ushort types[1] = { 29 };

    MonoTypical::find<MethylToHighBridge, 1>(target, indexes, types);
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
    else a->changeType(18);

    assert(b->is(23));
    b->changeType(19);

    assert(c->is(22));
    if (c->is(21)) c->changeType(2);
    else if (c->is(23)) c->changeType(8);
    else c->changeType(1);

    Finder::findAll(atoms, 3);
}
