#include "sierpinski_drop.h"
#include "sierpinski_drop_left.h"
#include "sierpinski_drop_right.h"

const char SierpinskiDrop::__name[] = "sierpinski drop";

double SierpinskiDrop::RATE()
{
    static double value = getRate("SIERPINSKI_DROP");
    return value;
}

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

    if (a->is(38)) a->changeType(13);
    else if (a->is(37)) a->changeType(27);
    else a->changeType(26);

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
