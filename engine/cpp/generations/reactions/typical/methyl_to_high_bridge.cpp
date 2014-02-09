#include "methyl_to_high_bridge.h"

const char MethylToHighBridge::__name[] = "methyl to high bridge";
const double MethylToHighBridge::RATE = 9.8e10 * std::exp(-15.3e3 / (1.98 * Env::T)); // REAL: A = 9.8e12

void MethylToHighBridge::find(MethylOnDimerCMsiu *target)
{
    create<MethylToHighBridge>(target);
}

void MethylToHighBridge::doIt()
{
    Atom *atoms[3] = { target()->atom(0), target()->atom(1), target()->atom(4) };
    Atom *a = atoms[0], *b = atoms[1], *c = atoms[2];

    assert(a->is(29));
    assert(b->is(23));
    assert(c->is(22));

    b->unbondFrom(c);
    b->bondWith(a);

    if (a->is(13)) a->changeType(17);
    else if (a->is(30)) a->changeType(16);
    else a->changeType(18);

    b->changeType(19);

    if (c->is(21)) c->changeType(2);
    else if (c->is(23)) c->changeType(8);
    else if (c->is(32)) c->changeType(5);
    else c->changeType(28);

    Finder::findAll(atoms, 3);
}
