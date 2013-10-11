#include <generations/atoms/c.h>
#include <generations/crystals/diamond.h>
#include <lattice.h>

using namespace vd;

int main(int argc, char const *argv[])
{
    Crystal *diamond = new Diamond(dim3(10, 10, 5));

    Lattice *lattice = new Lattice(diamond, int3(1, 1, 1));
    C c0(0, 1, lattice);
    assert(c0.lattice() == lattice);
    assert(c0.lattice()->coords().x == 1);
    assert(c0.lattice()->coords().y == 1);
    assert(c0.lattice()->coords().z == 1);

    C c4(3, 1, (Lattice *)0);
    assert(!c4.lattice());

    c0.bondWith(&c4);
    assert(c0.hasBondWith(&c4));
    assert(c4.hasBondWith(&c0));

    c4.unbondFrom(&c0);
    assert(!c0.hasBondWith(&c4));
    assert(!c4.hasBondWith(&c0));

    C c2(2, 0, new Lattice(diamond, int3(2, 2, 2)));
    assert(!c0.hasBondWith(&c2));
    assert(!c2.hasBondWith(&c0));

    c2.unsetLattice();
    assert(!c2.lattice());

    c2.setLattice(diamond, int3(3, 2, 1));
    assert(c2.lattice());
    assert(c2.lattice()->coords().x == 3);
    assert(c2.lattice()->coords().y == 2);
    assert(c2.lattice()->coords().z == 1);

    delete lattice;
    delete diamond;

    return 0;
}