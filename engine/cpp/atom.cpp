#include "atom.h"
#include "lattice.h"

#include <assert.h>

namespace vd
{

Atom::Atom(uint type, Lattice *lattice) : _type(type), _lattice(lattice), _cacheLattice(0)
{
}

Atom::~Atom()
{
    delete _lattice;
}

void Atom::bondWith(Atom *neighbour, int depth)
{
#pragma omp critical
    neighbours().insert(neighbour);

    if (depth > 0) neighbour->bondWith(this, 0);
}

bool Atom::hasBondWith(Atom *neighbour) const
{
    return neighbours().find(neighbour) != neighbours().cend();
}

void Atom::setLattice(Crystal *crystal, const int3 &coords)
{
    assert(crystal);
    assert(!_lattice);

    if (_cacheLattice)
    {
        if (!_cacheLattice->is(crystal))
        {
            _lattice = new Lattice(crystal, coords);
        }

        delete _cacheLattice;
        _cacheLattice = 0;
    }
    else
    {
        _lattice = new Lattice(crystal, coords);
    }
}

void Atom::unsetLattice()
{
    assert(_lattice);

    _lattice = 0;
    _cacheLattice = _lattice;
}

}
