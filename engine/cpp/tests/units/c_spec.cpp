#include <set>
#include <atoms/lattice.h>
#include <generations/atoms/c.h>
#include <generations/crystals/diamond.h>

using namespace vd;

#include <iostream>
using namespace std;

void assertIs(C *c, std::initializer_list<uint> types)
{
    std::set<uint> ts(types);
    for (int i = 0; i < 32; ++i)
    {
        bool result = (ts.find(i) != ts.cend());
        assert((!c->is(i) || result) && (c->is(i) || !result));
    }
}

int main(int argc, char const *argv[])
{
    Crystal *diamond = new Diamond(dim3(10, 10, 5));
    Lattice *lattice = new Lattice(diamond, int3(1, 1, 1));

    C c8(8, 1, lattice);
    c8.specifyType();
    assert(c8.lattice() == lattice);
    assert(c8.lattice()->coords().x == 1);
    assert(c8.lattice()->coords().y == 1);
    assert(c8.lattice()->coords().z == 1);
    assert(c8.type() == 8);
    assertIs(&c8, { 1, 3, 8, 9 });

    C c11(11, 1, (Lattice *)0);
    c11.specifyType();
    assert(!c11.lattice());
    assert(c11.type() == 26);
    assertIs(&c11, { 11, 14, 26, 29, 31 });

    c8.bondWith(&c11);
    assert(c8.hasBondWith(&c11));
    assert(c11.hasBondWith(&c8));

    c11.unbondFrom(&c8);
    assert(!c8.hasBondWith(&c11));
    assert(!c11.hasBondWith(&c8));

    C c3(3, 0, new Lattice(diamond, int3(2, 2, 2)));
    c3.specifyType();
    assert(!c8.hasBondWith(&c3));
    assert(!c3.hasBondWith(&c8));
    assert(c3.type() == 0);
    assertIs(&c3, { 0, 3 });

    c3.unsetLattice();
    assert(!c3.lattice());

    c3.setLattice(diamond, int3(3, 2, 1));
    assert(c3.lattice());
    assert(c3.lattice()->coords().x == 3);
    assert(c3.lattice()->coords().y == 2);
    assert(c3.lattice()->coords().z == 1);

    delete lattice;
    delete diamond;

    return 0;
}