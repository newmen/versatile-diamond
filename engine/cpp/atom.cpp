#include "atom.h"
#include "lattice.h"

//#include "locks.h"

#include <assert.h>

namespace vd
{

Atom::Atom(ushort type, ushort actives, Lattice *lattice) :
    _type(type), _actives(actives), _lattice(lattice), _cacheLattice(lattice)
{
}

Atom::~Atom()
{
    delete _lattice;
}

void Atom::changeType(ushort newType)
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
//#pragma omp critical
//    {
    set([this, &neighbour]() {
        assert(_actives > 0);

//    Locks::instance()->lock(this, [this, &neighbour]() {
        neighbours().insert(neighbour);
        deactivate();
    });
//    }

    if (depth > 0) neighbour->bondWith(this, 0);
}

void Atom::unbondFrom(Atom *neighbour, int depth)
{
//#pragma omp critical
//    {
    set([this, &neighbour]() {
        assert(hasBondWith(neighbour));

//    Locks::instance()->lock(this, [this, &neighbour]() {
        auto it = neighbours().find(neighbour);
        neighbours().erase(it);
        activate();
    });
//    }

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

void Atom::describe(ushort rType, BaseSpec *spec)
{
    set([this, rType, spec]() {
        _roles[rType].insert(spec->type());
        _specs.insert(std::pair<ushort, BaseSpec *>(spec->type(), spec));
    });
}

bool Atom::hasRole(ushort atomType, ushort specType) const
{
    auto specTypes = _roles.find(atomType);
    return specTypes != _roles.cend() && specTypes->second.find(specType) != specTypes->second.cend();
}

//void Atom::forget(BaseSpec *spec)
//{
//#pragma omp critical
//    _specs.erase(spec);
//}

}
