#include <set>
#include <generations/atoms/c.h>
#include <generations/crystals/diamond.h>
#include <lattice.h>

using namespace vd;

void assertIs(C *c, std::initializer_list<uint> types)
{
    std::set<uint> ts(types);
    for (int i = 0; i < 21; ++i)
    {
        bool result = (ts.find(i) != ts.cend());
        assert((!c->is(i) || result) && (c->is(i) || !result));
    }
}

int main(int argc, char const *argv[])
{
    Crystal *diamond = new Diamond(dim3(10, 10, 5));
    Lattice *lattice = new Lattice(diamond, int3(1, 1, 1));

    C c16(16, 1, lattice);
    assert(c16.lattice() == lattice);
    assert(c16.lattice()->coords().x == 1);
    assert(c16.lattice()->coords().y == 1);
    assert(c16.lattice()->coords().z == 1);
    c16.specifyType();
    assertIs(&c16, { 15, 16, 0 });

    C c3(3, 1, (Lattice *)0);
    assert(!c3.lattice());
    c3.specifyType();
    assertIs(&c3, { 12, 3 });

    c16.bondWith(&c3);
    assert(c16.hasBondWith(&c3));
    assert(c3.hasBondWith(&c16));

    c3.unbondFrom(&c16);
    assert(!c16.hasBondWith(&c3));
    assert(!c3.hasBondWith(&c16));

    C c2(2, 0, new Lattice(diamond, int3(2, 2, 2)));
    assert(!c16.hasBondWith(&c2));
    assert(!c2.hasBondWith(&c16));
    c2.specifyType();
    assertIs(&c2, { 2, 0 });

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