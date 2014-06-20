#include <set>
#include <handbook.h>
#include <atoms/c.h>

using namespace vd;

#include <iostream>
using namespace std;

void assertIs(C *c, std::initializer_list<uint> types)
{
    std::set<uint> ts(types);
    for (int i = 0; i < Handbook::__atomsNum; ++i)
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
    assertIs(&c8, { 1, 3, 7, 8, 9 });

    C c11(11, 1, (Lattice *)nullptr);
    c11.specifyType();
    assert(!c11.lattice());
    assert(c11.type() == 36);
    assertIs(&c11, { 11, 14, 25, 26, 29, 31, 35, 36 });

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

    C c10(10, 0, (Lattice *)nullptr);
    assertIs(&c10, { 10, 14 });

    C c37(37, 1, (Lattice *)nullptr);
    assertIs(&c37, { 10, 11, 14, 37 });

    C c38(38, 2, (Lattice *)nullptr);
    assertIs(&c38, { 10, 11, 12, 14, 37, 38 });

    delete lattice;
    delete diamond;

    return 0;
}
