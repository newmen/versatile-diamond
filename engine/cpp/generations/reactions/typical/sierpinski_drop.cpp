#include "sierpinski_drop.h"
#include "sierpinski_drop_left.h"
#include "sierpinski_drop_right.h"

const char SierpinskiDrop::__name[] = "serpynsky drop";
const double SierpinskiDrop::RATE = 4.4e9 * std::exp(-30e3 / (1.98 * Env::T));

void SierpinskiDrop::find(CrossBridgeOnBridges *target)
{
    create<SierpinskiDropLeft>(target);
    create<SierpinskiDropRight>(target);
}

void SierpinskiDrop::doItWith(Atom **atoms)
{
    assert(target()->type() == CrossBridgeOnBridges::ID);

    Atom *a = atoms[0], *b = atoms[1];
    assert(a->is(10));

    a->unbondFrom(b);

    a->changeType(26);

    if (b->is(23)) b->changeType(21);
    else if (b->is(33)) b->changeType(5);
    else if (b->is(8)) b->changeType(2);
    else
    {
        assert(b->is(7));
        b->changeType(28);
    }

    Finder::findAll(atoms, 2);
}
