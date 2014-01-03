#include "form_two_bond.h"

void FormTwoBond::find(MethylOnBridgeCBsCMsu *target)
{
    create<FormTwoBond>(target);
}

void FormTwoBond::doIt()
{
    assert(target()->type() == MethylOnBridgeCBsCMsu::ID);

    Atom *atoms[2] = { target()->atom(0), atoms[1] = target()->atom(1) };
    Atom *a = atoms[0], *b = atoms[1];

    assert(a->is(26));
    assert(b->is(8));

    a->bondWith(b);

    if (a->is(13)) a->changeType(17);
    else if (a->is(27)) a->changeType(16);
    else a->changeType(18);

    b->changeType(19);

    Finder::findAll(atoms, 2);
}
