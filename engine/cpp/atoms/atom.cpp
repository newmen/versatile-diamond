#include "atom.h"
#include "lattice.h"
#include "../species/base_spec.h"
//#include "../tools/locks.h"

#include <assert.h>

#ifdef PRINT
#include <iostream>
#endif // PRINT

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
#ifdef PARALLEL
#pragma omp atomic
#endif // PARALLEL
    ++_actives;
}

void Atom::deactivate()
{
    assert(_actives > 0);

#ifdef PARALLEL
#pragma omp atomic
#endif // PARALLEL
    --_actives;
}

void Atom::bondWith(Atom *neighbour, int depth)
{
#ifdef PARALLEL
    lock([this, &neighbour]() {
#endif // PARALLEL
        assert(_actives > 0);

        neighbours().insert(neighbour);
        deactivate();
#ifdef PARALLEL
    });
#endif // PARALLEL

    if (depth > 0) neighbour->bondWith(this, 0);
}

void Atom::unbondFrom(Atom *neighbour, int depth)
{
#ifdef PARALLEL
    lock([this, &neighbour]() {
#endif // PARALLEL
        assert(hasBondWith(neighbour));

        auto it = neighbours().find(neighbour);
        neighbours().erase(it);
        activate();
#ifdef PARALLEL
    });
#endif // PARALLEL

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

void Atom::describe(ushort rType, std::shared_ptr<BaseSpec> &spec)
{
#ifdef PARALLEL
    lock([this, rType, spec]() {
#endif // PARALLEL
        _roles[rType].insert(spec->type());

        const uint key = hash(rType, spec->type());
        _specs.insert(std::pair<uint, std::shared_ptr<BaseSpec>>(key, spec));
#ifdef PARALLEL
    });
#endif // PARALLEL
}

bool Atom::hasRole(ushort rType, ushort specType)
{
    bool result;
    const uint key = hash(rType, specType);

#ifdef PARALLEL
    lock([this, &result, key]() {
#endif // PARALLEL
        result = _specs.find(key) != _specs.end();
#ifdef PARALLEL
    });
#endif // PARALLEL

    return result;
}

BaseSpec *Atom::specByRole(ushort rType, ushort specType)
{
    BaseSpec *result;
    const uint key = hash(rType, specType);

#ifdef PARALLEL
    lock([this, &result, key]() {
#endif // PARALLEL
        auto its = _specs.equal_range(key);
        assert(std::distance(its.first, its.second) == 1);
        result = its.first->second.get();
#ifdef PARALLEL
    });
#endif // PARALLEL

    return result;
}

void Atom::forget(ushort rType, ushort specType)
{
    const uint key = hash(rType, specType);

#ifdef PARALLEL
    lock([this, rType, key]() {
#endif // PARALLEL
        _roles.erase(rType);
        _specs.erase(key);
#ifdef PARALLEL
    });
#endif // PARALLEL
}

#ifdef PRINT
void Atom::info()
{
    if (lattice()) std::cout << lattice()->coords();
    else std::cout << "amorph";
}
#endif // PRINT


}
