#include "form_two_bond.h"

const char FormTwoBond::__name[] = "form two bond";

double FormTwoBond::RATE()
{
    static double value = getRate("FORM_TWO_BOND");
    return value;
}

void FormTwoBond::find(MethylOnBridgeCBsCMsiu *target)
{
    create<FormTwoBond>(target);
}

void FormTwoBond::doIt()
{
    assert(target()->type() == MethylOnBridgeCBsCMsiu::ID);

    Atom *atoms[2] = { target()->atom(0), atoms[1] = target()->atom(1) };
    analyzeAndChangeAtoms(atoms, 2);
    Finder::findAll(atoms, 2);
}

void FormTwoBond::changeAtoms(Atom **atoms)
{
    Atom *a = atoms[0], *b = atoms[1];

    assert(a->is(26));
    assert(b->is(8));

    a->bondWith(b);

    if (a->is(13)) a->changeType(17);
    else if (a->is(27)) a->changeType(16);
    else a->changeType(18);

    b->changeType(19);
}
