#include <vector>
#include <generations/builders/atom_builder.h>
#include <generations/crystals/diamond.h>
using namespace vd;

#include "../support/open_diamond.h"

#include <iostream>

int main()
{
    std::vector<Atom *> atoms;
    AtomBuilder builder;
    OpenDiamond diamond;
    auto s = OpenDiamond::SIZES;

    diamond.initialize();

    auto buildCd = [&atoms, &diamond, &builder](int x, int y, int z)
    {
        Atom *atom = builder.buildCd(0, 0, &diamond, int3(x, y, z));
        atoms.push_back(atom);
        return atom;
    };

    Atom *c111 = buildCd(1, 1, 1);
    Atom *c222 = buildCd(2, 2, 2);
    Atom *c444 = buildCd(4, 4, 4);

    // 110
    auto nbrs = diamond.neighbours110(c111);
    assert(nbrs[0] == diamond.atom(int3(1, 0, 2)));
    assert(nbrs[1] == diamond.atom(int3(1, 1, 2)));
    assert(nbrs[2] == diamond.atom(int3(1, 1, 0)));
    assert(nbrs[3] == diamond.atom(int3(2, 1, 0)));

    nbrs = diamond.neighbours110(c222);
    assert(nbrs[0] == diamond.atom(int3(1, 2, 3)));
    assert(nbrs[1] == diamond.atom(int3(2, 2, 3)));
    assert(nbrs[2] == diamond.atom(int3(2, 2, 1)));
    assert(nbrs[3] == diamond.atom(int3(2, 3, 1)));

    nbrs = diamond.neighbours110(c444);
    assert(nbrs[0] == 0);
    assert(nbrs[1] == 0);

    // 100
    nbrs = diamond.neighbours100(c111);
    assert(nbrs[0] == diamond.atom(int3(1, 0, 1)));
    assert(nbrs[1] == diamond.atom(int3(1, 2, 1)));
    assert(nbrs[2] == diamond.atom(int3(0, 1, 1)));
    assert(nbrs[3] == diamond.atom(int3(2, 1, 1)));

    nbrs = diamond.neighbours100(c222);
    assert(nbrs[0] == diamond.atom(int3(1, 2, 2)));
    assert(nbrs[1] == diamond.atom(int3(3, 2, 2)));
    assert(nbrs[2] == diamond.atom(int3(2, 1, 2)));
    assert(nbrs[3] == diamond.atom(int3(2, 3, 2)));

    // default bonds
    assert(diamond.isBonded(int3(1, 1, 1), int3(1, 0, 2)));
    assert(diamond.isBonded(int3(1, 1, 1), int3(1, 1, 2)));
    assert(diamond.isBonded(int3(1, 1, 1), int3(1, 1, 0)));
    assert(diamond.isBonded(int3(1, 1, 1), int3(2, 1, 0)));

    assert(!diamond.isBonded(int3(1, 1, 1), int3(1, 0, 1)));
    assert(!diamond.isBonded(int3(1, 1, 1), int3(1, 2, 1)));
    assert(!diamond.isBonded(int3(1, 1, 1), int3(0, 1, 1)));
    assert(!diamond.isBonded(int3(1, 1, 1), int3(2, 1, 1)));

    // border atoms
    Atom *c001 = buildCd(0, 0, 1);
    Atom *c002 = buildCd(0, 0, 2);
    Atom *c991 = buildCd(s.x - 1, s.y - 1, 1);
    Atom *c992 = buildCd(s.x - 1, s.y - 1, 2);

    nbrs = diamond.neighbours110(c001);
    assert(diamond.isBonded(int3(0, 0, 1), int3(0, s.y - 1, 2)));
    assert(diamond.isBonded(int3(0, 0, 1), int3(0, 0, 2)));
    assert(diamond.isBonded(int3(0, 0, 1), int3(0, 0, 0)));
    assert(diamond.isBonded(int3(0, 0, 1), int3(1, 0, 0)));

    nbrs = diamond.neighbours110(c002);
    assert(diamond.isBonded(int3(0, 0, 2), int3(s.x - 1, 0, 3)));
    assert(diamond.isBonded(int3(0, 0, 2), int3(0, 0, 3)));
    assert(diamond.isBonded(int3(0, 0, 2), int3(0, 0, 1)));
    assert(diamond.isBonded(int3(0, 0, 2), int3(0, 1, 1)));

    nbrs = diamond.neighbours110(c991);
    assert(diamond.isBonded(int3(s.x - 1, s.y - 1, 1), int3(s.x - 1, s.y - 2, 2)));
    assert(diamond.isBonded(int3(s.x - 1, s.y - 1, 1), int3(s.x - 1, s.y - 1, 2)));
    assert(diamond.isBonded(int3(s.x - 1, s.y - 1, 1), int3(s.x - 1, s.y - 1, 0)));
    assert(diamond.isBonded(int3(s.x - 1, s.y - 1, 1), int3(0, s.y - 1, 0)));

    nbrs = diamond.neighbours110(c992);
    assert(diamond.isBonded(int3(s.x - 1, s.y - 1, 2), int3(s.x - 2, s.y - 1, 3)));
    assert(diamond.isBonded(int3(s.x - 1, s.y - 1, 2), int3(s.x - 1, s.y - 1, 3)));
    assert(diamond.isBonded(int3(s.x - 1, s.y - 1, 2), int3(s.x - 1, s.y - 1, 1)));
    assert(diamond.isBonded(int3(s.x - 1, s.y - 1, 2), int3(s.x - 1, 0, 1)));

    // front_110(a, b)
    Atom *c000 = buildCd(0, 0, 0);
    Atom *c100 = buildCd(1, 0, 0);
    Atom *cx00 = buildCd(s.x, 0, 0);
    auto coords = int3(0, 0, 1);
    assert(DiamondRelations::front_110(c000, c100) == coords);
    assert(DiamondRelations::front_110(c100, c000) == coords);
    coords = int3(s.x, 0, 1);
    std::cout << DiamondRelations::front_110(c000, cx00) << std::endl;
    assert(DiamondRelations::front_110(c000, cx00) == coords);
    assert(DiamondRelations::front_110(cx00, c000) == coords);

    Atom *c101 = buildCd(1, 0, 1);
    Atom *c1y1 = buildCd(1, s.y, 1);
    coords = int3(1, 0, 2);
    assert(DiamondRelations::front_110(c101, c111) == coords);
    assert(DiamondRelations::front_110(c111, c101) == coords);
    coords = int3(1, s.y, 2);
    assert(DiamondRelations::front_110(c101, c1y1) == coords);
    assert(DiamondRelations::front_110(c1y1, c101) == coords);

    for (Atom *atom : atoms) delete atom;

    return 0;
}
