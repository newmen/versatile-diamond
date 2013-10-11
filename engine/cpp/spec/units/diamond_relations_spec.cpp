#include <generations/crystals/diamond.h>
using namespace vd;

class Checker : public Diamond
{
public:
    typedef Neighbours<4> FN;

    Checker() : Diamond(dim3(10, 10, 10), 4) {}

    Atom *atom(const int3 &coords) { return atoms()[coords]; }

    FN neighbours110(const int3 &coords)
    {
        TN f110 = front_110(atoms(), coords);
        TN c110 = cross_110(atoms(), coords);
        Atom *nbrs[4] = { f110[0], f110[1], c110[0], c110[1] };
        return FN(nbrs);
    }

    FN neighbours100(const int3 &coords)
    {
        TN f100 = front_100(atoms(), coords);
        TN c100 = cross_100(atoms(), coords);
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
    Checker checker;
    checker.initialize();

    // 110
    auto nbrs = checker.neighbours110(int3(1, 1, 1));
    assert(nbrs[0] == checker.atom(int3(1, 0, 2)));
    assert(nbrs[1] == checker.atom(int3(1, 1, 2)));
    assert(nbrs[2] == checker.atom(int3(1, 1, 0)));
    assert(nbrs[3] == checker.atom(int3(2, 1, 0)));

    nbrs = checker.neighbours110(int3(2, 2, 2));
    assert(nbrs[0] == checker.atom(int3(1, 2, 3)));
    assert(nbrs[1] == checker.atom(int3(2, 2, 3)));
    assert(nbrs[2] == checker.atom(int3(2, 2, 1)));
    assert(nbrs[3] == checker.atom(int3(2, 3, 1)));

    nbrs = checker.neighbours110(int3(4, 4, 4));
    assert(nbrs[0] == 0);
    assert(nbrs[1] == 0);

    // 100
    nbrs = checker.neighbours100(int3(1, 1, 1));
    assert(nbrs[0] == checker.atom(int3(1, 0, 1)));
    assert(nbrs[1] == checker.atom(int3(1, 2, 1)));
    assert(nbrs[2] == checker.atom(int3(0, 1, 1)));
    assert(nbrs[3] == checker.atom(int3(2, 1, 1)));

    nbrs = checker.neighbours100(int3(2, 2, 2));
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
    nbrs = checker.neighbours110(int3(0, 0, 1));
    assert(checker.isBonded(int3(0, 0, 1), int3(0, 9, 2)));
    assert(checker.isBonded(int3(0, 0, 1), int3(0, 0, 2)));
    assert(checker.isBonded(int3(0, 0, 1), int3(0, 0, 0)));
    assert(checker.isBonded(int3(0, 0, 1), int3(1, 0, 0)));

    nbrs = checker.neighbours110(int3(0, 0, 2));
    assert(checker.isBonded(int3(0, 0, 2), int3(9, 0, 3)));
    assert(checker.isBonded(int3(0, 0, 2), int3(0, 0, 3)));
    assert(checker.isBonded(int3(0, 0, 2), int3(0, 0, 1)));
    assert(checker.isBonded(int3(0, 0, 2), int3(0, 1, 1)));

    nbrs = checker.neighbours110(int3(9, 9, 1));
    assert(checker.isBonded(int3(9, 9, 1), int3(9, 8, 2)));
    assert(checker.isBonded(int3(9, 9, 1), int3(9, 9, 2)));
    assert(checker.isBonded(int3(9, 9, 1), int3(9, 9, 0)));
    assert(checker.isBonded(int3(9, 9, 1), int3(0, 9, 0)));

    nbrs = checker.neighbours110(int3(9, 9, 2));
    assert(checker.isBonded(int3(9, 9, 2), int3(8, 9, 3)));
    assert(checker.isBonded(int3(9, 9, 2), int3(9, 9, 3)));
    assert(checker.isBonded(int3(9, 9, 2), int3(9, 9, 1)));
    assert(checker.isBonded(int3(9, 9, 2), int3(9, 0, 1)));

    return 0;
}
