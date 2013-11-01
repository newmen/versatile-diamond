#include "atom.h"
#include "lattice.h"
#include "../species/specific_spec.h"

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
    delete _cacheLattice;
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
    auto &currRelatives = neighbour->lattice() ? _crystalRelatives : _amorphRelatives;

#ifdef PARALLEL
    lock([this, &currRelatives, neighbour]() {
#endif // PARALLEL
        assert(_actives > 0);

        currRelatives.insert(neighbour);
        deactivate();
#ifdef PARALLEL
    });
#endif // PARALLEL

    if (depth > 0) neighbour->bondWith(this, 0);
}

void Atom::unbondFrom(Atom *neighbour, int depth)
{
    auto &currRelatives = neighbour->lattice() ? _crystalRelatives : _amorphRelatives;

#ifdef PARALLEL
    lock([this, &currRelatives, neighbour]() {
#endif // PARALLEL
        auto it = currRelatives.find(neighbour);
        assert(it != currRelatives.end());

        currRelatives.erase(it);
        activate();
#ifdef PARALLEL
    });
#endif // PARALLEL

    if (depth > 0) neighbour->unbondFrom(this, 0);
}

bool Atom::hasBondWith(Atom *neighbour) const
{
    return _crystalRelatives.find(neighbour) != _crystalRelatives.cend() ||
            _amorphRelatives.find(neighbour) != _amorphRelatives.cend();
}

Atom *Atom::amorphNeighbour()
{
    Atom *result = nullptr;

#ifdef PARALLEL
    lock([this, &result]() {
#endif // PARALLEL
        assert(_amorphRelatives.size() == 1);
        result = *_amorphRelatives.begin();
#ifdef PARALLEL
    });
#endif // PARALLEL

    return result;
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
    _lattice = nullptr;
}

void Atom::describe(ushort rType, BaseSpec *spec)
{
    const uint key = hash(rType, spec->type());

#ifdef PRINT
#ifdef PARALLEL
#pragma omp critical (print)
#endif // PARALLEL
        std::cout << "describe " << this << std::dec << " |" << type() << ", " << _prevType << "| role type: " << rType
                  << ". spec type: " << spec->type() << ". key: " << key << std::endl;
#endif // PRINT

#ifdef PARALLEL
    lock([this, rType, spec, key]() {
#endif // PARALLEL
        _roles[rType].insert(spec->type());
        _specs.insert(std::pair<uint, BaseSpec *>(key, spec));
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
    BaseSpec *result = nullptr;
    const uint key = hash(rType, specType);

#ifdef PRINT
#ifdef PARALLEL
#pragma omp critical (print)
    {
#endif // PARALLEL
        std::cout << "specByRole " << this << std::dec << " |" << type() << ", " << _prevType << "| role type: " << rType
                  << ". spec type: " << specType << ". key: " << key;
        auto er = _specs.equal_range(key);
        std::cout << " -> distance: " << std::distance(er.first, er.second) << std::endl;
#ifdef PARALLEL
    }
#endif // PARALLEL
#endif // PRINT

#ifdef PARALLEL
    lock([this, &result, key]() {
#endif // PARALLEL
        auto its = _specs.equal_range(key);
        uint distance = std::distance(its.first, its.second);
        if (distance > 0)
        {
            assert(distance == 1);
            result = its.first->second;
        }
#ifdef PARALLEL
    });
#endif // PARALLEL

    return result;
}

SpecificSpec *Atom::specificSpecByRole(ushort rType, ushort specType)
{
    return static_cast<SpecificSpec *>(specByRole(rType, specType));
}

void Atom::forget(ushort rType, BaseSpec *spec)
{
    const uint key = hash(rType, spec->type());

#ifdef PRINT
#ifdef PARALLEL
#pragma omp critical (print)
#endif // PARALLEL
    std::cout << "forget " << this << std::dec << " |" << type() << ", " << _prevType << "| role type: " << rType
              << ". spec type: " << spec->type() << ". key: " << key << std::endl;
#endif // PRINT

#ifdef PARALLEL
    lock([this, rType, spec, key]() {
#endif // PARALLEL
        auto its = _specs.equal_range(key);
        if (std::distance(its.first, its.second) == 1) _roles.erase(rType);

        while (its.first != its.second)
        {
            if ((its.first++)->second == spec)
            {
                _specs.erase(key);
                break;
            }
        }

#ifdef PARALLEL
    });
#endif // PARALLEL

}

void Atom::prepareToRemove()
{
    _prevType = _type;
    setType(NO_VALUE);
}

#ifdef PRINT
void Atom::info()
{
//#pragma omp critical (print)
    {
        std::cout << type() << " -> ";
        if (lattice()) std::cout << lattice()->coords();
        else std::cout << "amorph";

        std::cout << " %% roles: ";
        for (const auto &pr : _roles)
        {
            std::cout << pr.first << "";
            for (ushort st : pr.second) std::cout << " , " << st << " => " << hash(pr.first, st);
            std::cout << " | ";
        }

        std::cout << " %% specs: ";
        for (const auto &pr : _specs)
        {
            std::cout << pr.first << " -> " << pr.second << " # ";
        }
    }
}
#endif // PRINT


}
