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

void Atom::changeType(uint newType)
{
    _prevType = _type;
    setType(newType);
    specifyType();
}

void Atom::activate()
{
#pragma omp atomic
    ++_actives;
}

void Atom::deactivate()
{
    assert(_actives > 0);

#pragma omp atomic
    --_actives;
}

void Atom::bondWith(Atom *neighbour, int depth)
{
    assert(_actives > 0);

#pragma omp critical // TODO: подумать тут! можно сделать так, чтобы при обходе не возникало ситуации, когда нужно блокировать
    neighbours().insert(neighbour);

    deactivate();
    if (depth > 0) neighbour->bondWith(this, 0);
}

void Atom::unbondFrom(Atom *neighbour, int depth)
{
    assert(hasBondWith(neighbour));

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

    if (_cacheLattice && _cacheLattice->crystal() == crystal)
    {
        _lattice = _cacheLattice;
        _lattice->updateCoords(coords);
    }
    else
    {
        delete _cacheLattice;
        _cacheLattice = _lattice = new Lattice(crystal, coords);
    }
}

void Atom::unsetLattice()
{
    assert(_lattice);

    _cacheLattice = _lattice;
    _lattice = 0;
}

//void Atom::describe(BaseSpec *spec)
//{
//#pragma omp critical // TODO: подумать тут! можно сделать так, чтобы при обходе не возникало ситуации, когда нужно блокировать
//    _specs.insert(spec);
//}

//void Atom::forget(BaseSpec *spec)
//{
//#pragma omp critical
//    _specs.erase(spec);
//}

}
