#include <vector>
#include <generations/crystals/diamond.h>
#include <generations/builders/diamond_atom_builder.h>
using namespace vd;

class Checker : public Diamond
{
public:
    typedef Neighbours<4> FN;

    Checker() : Diamond(dim3(10, 10, 10), 4) {}

    Atom *atom(const int3 &coords) { return atoms()[coords]; }

    FN neighbours110(const Atom *atom)
    {
        TN f110 = front_110(atoms(), atom);
        TN c110 = cross_110(atoms(), atom);
        Atom *nbrs[4] = { f110[0], f110[1], c110[0], c110[1] };
        return FN(nbrs);
    }

    FN neighbours100(const Atom *atom)
    {
        TN f100 = front_100(atoms(), atom);
        TN c100 = cross_100(atoms(), atom);
        Atom *nbrs[4] = { f100[0], f100[1], c100[0], c100[1] };
        return FN(nbrs);
    }

    bool isBonded(const int3 &a, const int3 &b)
    {
        Atom *aa = atom(a), *bb = atom(b);
        return aa->hasBondWith(bb) && bb->hasBondWith(aa);
    }
};

int main(int argc, char const *argv[])
{
    std::vector<Atom *> atoms;

    Checker checker;
    checker.initialize();

    DiamondAtomBuilder builder;
    auto buildCd = [&atoms, &checker, &builder](int x, int y, int z)
    {
        Atom *atom = builder.buildCd(0, 0, &checker, int3(x, y, z));
        atoms.push_back(atom);
        return atom;
    };

    Atom *c111 = buildCd(1, 1, 1);
    Atom *c222 = buildCd(2, 2, 2);
    Atom *c444 = buildCd(4, 4, 4);

    // 110
    auto nbrs = checker.neighbours110(c111);
    assert(nbrs[0] == checker.atom(int3(1, 0, 2)));
    assert(nbrs[1] == checker.atom(int3(1, 1, 2)));
    assert(nbrs[2] == checker.atom(int3(1, 1, 0)));
    assert(nbrs[3] == checker.atom(int3(2, 1, 0)));

    nbrs = checker.neighbours110(c222);
    assert(nbrs[0] == checker.atom(int3(1, 2, 3)));
    assert(nbrs[1] == checker.atom(int3(2, 2, 3)));
    assert(nbrs[2] == checker.atom(int3(2, 2, 1)));
    assert(nbrs[3] == checker.atom(int3(2, 3, 1)));

    nbrs = checker.neighbours110(c444);
    assert(nbrs[0] == 0);
    assert(nbrs[1] == 0);

    // 100
    nbrs = checker.neighbours100(c111);
    assert(nbrs[0] == checker.atom(int3(1, 0, 1)));
    assert(nbrs[1] == checker.atom(int3(1, 2, 1)));
    assert(nbrs[2] == checker.atom(int3(0, 1, 1)));
    assert(nbrs[3] == checker.atom(int3(2, 1, 1)));

    nbrs = checker.neighbours100(c222);
    assert(nbrs[0] == checker.atom(int3(1, 2, 2)));
    assert(nbrs[1] == checker.atom(int3(3, 2, 2)));
    assert(nbrs[2] == checker.atom(int3(2, 1, 2)));
    assert(nbrs[3] == checker.atom(int3(2, 3, 2)));

    // default bonds
    assert(checker.isBonded(int3(1, 1, 1), int3(1, 0, 2)));
    assert(checker.isBonded(int3(1, 1, 1), int3(1, 1, 2)));
    assert(checker.isBonded(int3(1, 1, 1), int3(1, 1, 0)));
    assert(checker.isBonded(int3(1, 1, 1), int3(2, 1, 0)));

    assert(!checker.isBonded(int3(1, 1, 1), int3(1, 0, 1)));
    assert(!checker.isBonded(int3(1, 1, 1), int3(1, 2, 1)));
    assert(!checker.isBonded(int3(1, 1, 1), int3(0, 1, 1)));
    assert(!checker.isBonded(int3(1, 1, 1), int3(2, 1, 1)));

    // border atoms
    Atom *c001 = buildCd(0, 0, 1);
    Atom *c002 = buildCd(0, 0, 2);
    Atom *c991 = buildCd(9, 9, 1);
    Atom *c992 = buildCd(9, 9, 2);

    nbrs = checker.neighbours110(c001);
    assert(checker.isBonded(int3(0, 0, 1), int3(0, 9, 2)));
    assert(checker.isBonded(int3(0, 0, 1), int3(0, 0, 2)));
    assert(checker.isBonded(int3(0, 0, 1), int3(0, 0, 0)));
    assert(checker.isBonded(int3(0, 0, 1), int3(1, 0, 0)));

    nbrs = checker.neighbours110(c002);
    assert(checker.isBonded(int3(0, 0, 2), int3(9, 0, 3)));
    assert(checker.isBonded(int3(0, 0, 2), int3(0, 0, 3)));
    assert(checker.isBonded(int3(0, 0, 2), int3(0, 0, 1)));
    assert(checker.isBonded(int3(0, 0, 2), int3(0, 1, 1)));

    nbrs = checker.neighbours110(c991);
    assert(checker.isBonded(int3(9, 9, 1), int3(9, 8, 2)));
    assert(checker.isBonded(int3(9, 9, 1), int3(9, 9, 2)));
    assert(checker.isBonded(int3(9, 9, 1), int3(9, 9, 0)));
    assert(checker.isBonded(int3(9, 9, 1), int3(0, 9, 0)));

    nbrs = checker.neighbours110(c992);
    assert(checker.isBonded(int3(9, 9, 2), int3(8, 9, 3)));
    assert(checker.isBonded(int3(9, 9, 2), int3(9, 9, 3)));
    assert(checker.isBonded(int3(9, 9, 2), int3(9, 9, 1)));
    assert(checker.isBonded(int3(9, 9, 2), int3(9, 0, 1)));

    for (Atom *atom : atoms) delete atom;

    return 0;
}
