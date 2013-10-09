#include "atom.h"
#include <assert.h>

namespace vd
{

IAtom::IAtom(uint type, const Lattice *lattice) : _type(type), _lattice(lattice), _hasLattice(lattice != 0)
{
}

IAtom::~IAtom()
{
    delete _lattice;
}

void IAtom::bondWith(IAtom *neighbour)
{
    neighbours().insert(neighbour);
}

bool IAtom::hasBondWith(IAtom *neighbour) const
{
    return neighbours().find(neighbour) != neighbours().cend();
}

}
