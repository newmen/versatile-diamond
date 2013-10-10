#include "atom.h"
#include "lattice.h"
#include <assert.h>

namespace vd
{

Atom::Atom(uint type, Lattice *lattice) : _type(type), _lattice(lattice), _hasLattice(lattice != 0)
{
}

Atom::~Atom()
{
    delete _lattice;
}

void Atom::bondWith(Atom *neighbour)
{
    neighbours().insert(neighbour);
}

bool Atom::hasBondWith(Atom *neighbour) const
{
    return neighbours().find(neighbour) != neighbours().cend();
}

}
