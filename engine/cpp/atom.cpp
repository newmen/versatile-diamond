#include "atom.h"
#include "lattice.h"

#include <assert.h>

namespace vd
{

Atom::Atom(uint type, uint actives, Lattice *lattice) :
    _type(type), _actives(actives), _lattice(lattice), _cacheLattice(lattice)
{
}

Atom::~Atom()
{
    delete _lattice;
}

void Atom::activate()
{
#pragma omp atomic
    ++_actives;
}

void Atom::deactivate()
{
#pragma omp atomic
    --_actives;
}

void Atom::bondWith(Atom *neighbour, int depth)
{
    assert(_actives > 0);

#pragma omp critical
    neighbours().insert(neighbour);

    deactivate();
    if (depth > 0) neighbour->bondWith(this, 0);
}

void Atom::unbondFrom(Atom *neighbour, int depth)
{
#pragma omp critical
    {
        auto it = neighbours().find(neighbour);
        neighbours().erase(it);
    }

    activate();
    if (depth > 0) neighbour->unbondFrom(this, 0);
}

bool Atom::hasBondWith(Atom *neighbour) const
{
    return neighbours().find(neighbour) != neighbours().cend();
}

void Atom::setLattice(Crystal *crystal, const int3 &coords)
{
    assert(crystal);
    assert(!_lattice);

    if (_cacheLattice && _cacheLattice->is(crystal))
    {
        _lattice = _cacheLattice;
        _lattice->updateCoords(coords);
    }
    else
    {
        _cacheLattice = _lattice = new Lattice(crystal, coords);
    }
}

void Atom::unsetLattice()
{
    assert(_lattice);

    _cacheLattice = _lattice;
    _lattice = 0;
}

}
