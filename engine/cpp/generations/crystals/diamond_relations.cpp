#include "diamond_relations.h"
#include "diamond.h"
#include "common.h"

DiamondRelations::TN DiamondRelations::front_110(const Diamond *diamond, const Atom *atom)
{
    assert(atom->lattice());
    const int3 &coords = atom->lattice()->coords();

    Atom *twoAtoms[2];
    if (coords.z % 2 == 0)
    {
        twoAtoms[0] = diamond->atom(int3(coords.x - 1, coords.y, coords.z + 1));
    }
    else
    {
        twoAtoms[0] = diamond->atom(int3(coords.x, coords.y - 1, coords.z + 1));
    }
    twoAtoms[1] = diamond->atom(int3(coords.x, coords.y, coords.z + 1));

    return TN(twoAtoms);
}

DiamondRelations::TN DiamondRelations::cross_110(const Diamond *diamond, const Atom *atom)
{
    assert(atom->lattice());
    const int3 &coords = atom->lattice()->coords();

    Atom *twoAtoms[2];

    twoAtoms[0] = diamond->atom(int3(coords.x, coords.y, coords.z - 1));
    if (coords.z % 2 == 0)
    {
        twoAtoms[1] = diamond->atom(int3(coords.x, coords.y + 1, coords.z - 1));
    }
    else
    {
        twoAtoms[1] = diamond->atom(int3(coords.x + 1, coords.y, coords.z - 1));
    }

    return TN(twoAtoms);
}

DiamondRelations::TN DiamondRelations::front_100(const Diamond *diamond, const Atom *atom)
{
    assert(atom->lattice());
    const int3 &coords = atom->lattice()->coords();

    Atom *twoAtoms[2];
    if (coords.z % 2 == 0)
    {
        twoAtoms[0] = diamond->atom(int3(coords.x - 1, coords.y, coords.z));
        twoAtoms[1] = diamond->atom(int3(coords.x + 1, coords.y, coords.z));
    }
    else
    {
        twoAtoms[0] = diamond->atom(int3(coords.x, coords.y - 1, coords.z));
        twoAtoms[1] = diamond->atom(int3(coords.x, coords.y + 1, coords.z));
    }
    return TN(twoAtoms);
}

DiamondRelations::TN DiamondRelations::cross_100(const Diamond *diamond, const Atom *atom)
{
    assert(atom->lattice());
    const int3 &coords = atom->lattice()->coords();

    Atom *twoAtoms[2];
    if (coords.z % 2 == 0)
    {
        twoAtoms[0] = diamond->atom(int3(coords.x, coords.y - 1, coords.z));
        twoAtoms[1] = diamond->atom(int3(coords.x, coords.y + 1, coords.z));
    }
    else
    {
        twoAtoms[0] = diamond->atom(int3(coords.x - 1, coords.y, coords.z));
        twoAtoms[1] = diamond->atom(int3(coords.x + 1, coords.y, coords.z));
    }
    return TN(twoAtoms);
}
