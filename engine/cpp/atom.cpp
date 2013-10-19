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
    lock([this, &neighbour]() {
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
    lock([this, &neighbour]() {
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
    lock([this, rType, spec]() {
        _roles[rType].insert(spec->type());

        const uint key = hash(rType, spec->type());
        _specs.insert(std::pair<uint, BaseSpec *>(key, spec));
    });
}

bool Atom::hasRole(ushort rType, ushort specType)
{
    bool result;
    const uint key = hash(rType, specType);
    lock([this, &result, key]() {
        result = _specs.find(key) != _specs.end();
    });
    return result;
}

BaseSpec *Atom::specByRole(ushort rType, ushort specType)
{
    BaseSpec *result;
    const uint key = hash(rType, specType);
    lock([this, &result, key]() {
        auto its = _specs.equal_range(key);
        assert(std::distance(its.first, its.second) == 1);
        result = its.first->second;
    });
    return result;
}

//void Atom::forget(BaseSpec *spec)
//{
//#pragma omp critical
//    _specs.erase(spec);
//}

}
