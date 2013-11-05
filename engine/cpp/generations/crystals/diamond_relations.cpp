#include "diamond_relations.h"
#include <algorithm>

DiamondRelations::TN DiamondRelations::front_110(const Crystal *crystal, const Atom *atom)
{
    assert(atom->lattice());
    const int3 &coords = atom->lattice()->coords();

    Atom *twoAtoms[2];
    if (coords.z % 2 == 0)
    {
        twoAtoms[0] = crystal->atom(int3(coords.x - 1, coords.y, coords.z + 1));
    }
    else
    {
        twoAtoms[0] = crystal->atom(int3(coords.x, coords.y - 1, coords.z + 1));
    }
    twoAtoms[1] = crystal->atom(int3(coords.x, coords.y, coords.z + 1));

    return TN(twoAtoms);
}

DiamondRelations::TN DiamondRelations::cross_110(const Crystal *crystal, const Atom *atom)
{
    assert(atom->lattice());
    const int3 &coords = atom->lattice()->coords();

    Atom *twoAtoms[2];

    twoAtoms[0] = crystal->atom(int3(coords.x, coords.y, coords.z - 1));
    if (coords.z % 2 == 0)
    {
        twoAtoms[1] = crystal->atom(int3(coords.x, coords.y + 1, coords.z - 1));
    }
    else
    {
        twoAtoms[1] = crystal->atom(int3(coords.x + 1, coords.y, coords.z - 1));
    }

    return TN(twoAtoms);
}

DiamondRelations::TN DiamondRelations::front_100(const Crystal *crystal, const Atom *atom)
{
    assert(atom->lattice());
    const int3 &coords = atom->lattice()->coords();

    Atom *twoAtoms[2];
    if (coords.z % 2 == 0)
    {
        twoAtoms[0] = crystal->atom(int3(coords.x - 1, coords.y, coords.z));
        twoAtoms[1] = crystal->atom(int3(coords.x + 1, coords.y, coords.z));
    }
    else
    {
        twoAtoms[0] = crystal->atom(int3(coords.x, coords.y - 1, coords.z));
        twoAtoms[1] = crystal->atom(int3(coords.x, coords.y + 1, coords.z));
    }
    return TN(twoAtoms);
}

DiamondRelations::TN DiamondRelations::cross_100(const Crystal *crystal, const Atom *atom)
{
    assert(atom->lattice());
    const int3 &coords = atom->lattice()->coords();

    Atom *twoAtoms[2];
    if (coords.z % 2 == 0)
    {
        twoAtoms[0] = crystal->atom(int3(coords.x, coords.y - 1, coords.z));
        twoAtoms[1] = crystal->atom(int3(coords.x, coords.y + 1, coords.z));
    }
    else
    {
        twoAtoms[0] = crystal->atom(int3(coords.x - 1, coords.y, coords.z));
        twoAtoms[1] = crystal->atom(int3(coords.x + 1, coords.y, coords.z));
    }
    return TN(twoAtoms);
}

int3 DiamondRelations::front_110(const Atom *first, const Atom *second)
{
    assert(first->lattice());
    assert(second->lattice());

    const int3 &a = first->lattice()->coords();
    const int3 &b = second->lattice()->coords();
    assert(a.z == b.z);

    if (a.z % 2 == 0)
    {
        assert(a.x != b.x);
        assert(a.y == b.y);
        if (std::abs(a.x - b.x) == 1)
        {
            return int3(std::min(a.x, b.x), a.y, a.z + 1);
        }
        else
        {
            assert(a.x == 0 || b.x == 0);
            return int3(std::max(a.x, b.x), a.y, a.z + 1);
        }
    }
    else
    {
        assert(a.x == b.x);
        assert(a.y != b.y);
        if (std::abs(a.y - b.y) == 1)
        {
            return int3(a.x, std::min(a.y, b.y), a.z + 1);
        }
        else
        {
            assert(a.y == 0 || b.y == 0);
            return int3(a.x, std::max(a.y, b.y), a.z + 1);
        }
    }
}
