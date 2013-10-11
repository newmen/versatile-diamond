#include "diamond.h"

#include <assert.h>

Diamond::Diamond(const dim3 &sizes, int defaultSurfaceHeight) :
    DiamondWithoutRelations(sizes), _defaultSurfaceHeight(defaultSurfaceHeight)
{
}

void Diamond::buildAtoms()
{
    for (int i = 0; i < _defaultSurfaceHeight - 1; ++i)
    {
        makeLayer(i, 8);
    }
    makeLayer(_defaultSurfaceHeight - 1, 0);
}

void Diamond::bondAllAtoms()
{
    atoms().each([this](Atom *atom) {
        if (!atom) return;
        assert(atom->lattice());

        int z = atom->lattice()->coords().z;
        if (z == _defaultSurfaceHeight - 1)
        {
            bondWithCross110(atom);
        }
        else if (atom->lattice()->coords().z == 0)
        {
            bondWithFront110(atom);
        }
        else
        {
            bondWithFront110(atom);
            bondWithCross110(atom);
        }

    });
}

Atom *Diamond::makeAtom(uint type, const int3 &coords)
{
    DiamondAtomBuilder builder;
    return builder.buildCd(type, this, coords);
}

void Diamond::bondWithFront110(Atom *atom)
{
    TN neighbours = this->front_110(this->atoms(), atom->lattice()->coords());
    bondWithNeighbours(atom, neighbours);
}

void Diamond::bondWithCross110(Atom *atom)
{
    TN neighbours = this->cross_110(this->atoms(), atom->lattice()->coords());
    bondWithNeighbours(atom, neighbours);
}

void Diamond::bondWithNeighbours(Atom *atom, DiamondRelations::TN &neighbours)
{
    assert(neighbours.all());
    atom->bondWith(neighbours[0]);
    atom->bondWith(neighbours[1]);
}
