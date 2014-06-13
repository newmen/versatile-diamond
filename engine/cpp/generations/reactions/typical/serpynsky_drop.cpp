#include "serpynsky_drop.h"

const char SerpynskyDrop::__name[] = "serrpynsky drop";
const double SerpynskyDrop::RATE = 4.4e9 * std::exp(-30e3 / (1.98 * Env::T));


void SerpynskyDrop::find(CrossBridgeOnBridges *target)
{
    create<SerpynskyDrop>(target);
}

void SerpynskyDrop::doIt()
{
    assert(target()->type() == CrossBridgeOnBridges::ID);

    Atom *atoms[2] = { target()->atom(0), target()->atom(1) };
    Atom *a = atoms[0], *b = atoms[1];

    assert(a->is(10));

    a->unbondFrom(b);

    a->changeType(26);

    if (b->is(23)) b->changeType(21);
    else if (b->is(33)) b->changeType(5);
    else
    {
        assert(a->is(7));
        b->changeType(8);
    }

    Finder::findAll(atoms, 2);
}
