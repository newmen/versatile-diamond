#ifndef DIAMOND_RELATIONS_H
#define DIAMOND_RELATIONS_H

#include "common.h"
#include "crystal.h"
#include "neighbours.h"

using namespace vd;

class DiamondRelations
{
public:
    typedef Neighbours<2> TN;

protected:
    TN front_110(const Crystal::Atoms &atoms, const int3 &coords) const
    {
        Atom *twoAtoms[2];
        if (coords.z % 2 == 0)
        {
            twoAtoms[0] = atoms[int3(coords.x - 1, coords.y, coords.z + 1)];
        }
        else
        {
            twoAtoms[0] = atoms[int3(coords.x, coords.y - 1, coords.z + 1)];
        }
        twoAtoms[1] = atoms[int3(coords.x, coords.y, coords.z + 1)];

        return TN(twoAtoms);
    }

    TN cross_110(const Crystal::Atoms &atoms, const int3 &coords) const
    {
        Atom *twoAtoms[2];

        twoAtoms[0] = atoms[int3(coords.x, coords.y, coords.z - 1)];
        if (coords.z % 2 == 0)
        {
            twoAtoms[1] = atoms[int3(coords.x, coords.y + 1, coords.z - 1)];
        }
        else
        {
            twoAtoms[1] = atoms[int3(coords.x + 1, coords.y, coords.z - 1)];
        }

        return TN(twoAtoms);
    }

    TN front_100(const Crystal::Atoms &atoms, const int3 &coords) const
    {
        Atom *twoAtoms[2];
        if (coords.z % 2 == 0)
        {
            twoAtoms[0] = atoms[int3(coords.x - 1, coords.y, coords.z)];
            twoAtoms[1] = atoms[int3(coords.x + 1, coords.y, coords.z)];
        }
        else
        {
            twoAtoms[0] = atoms[int3(coords.x, coords.y - 1, coords.z)];
            twoAtoms[1] = atoms[int3(coords.x, coords.y + 1, coords.z)];
        }
        return TN(twoAtoms);
    }

    TN cross_100(const Crystal::Atoms &atoms, const int3 &coords) const
    {
        Atom *twoAtoms[2];
        if (coords.z % 2 == 0)
        {
            twoAtoms[0] = atoms[int3(coords.x, coords.y - 1, coords.z)];
            twoAtoms[1] = atoms[int3(coords.x, coords.y + 1, coords.z)];
        }
        else
        {
            twoAtoms[0] = atoms[int3(coords.x - 1, coords.y, coords.z)];
            twoAtoms[1] = atoms[int3(coords.x + 1, coords.y, coords.z)];
        }
        return TN(twoAtoms);
    }
};

#endif // DIAMOND_RELATIONS_H
