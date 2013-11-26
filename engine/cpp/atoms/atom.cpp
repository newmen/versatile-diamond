#include "atom.h"
#include "lattice.h"
#include "../species/specific_spec.h"

#include <assert.h>

#ifdef PRINT
#include <iostream>
#include "../tools/debug_print.h"
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
    ++_actives;
}

void Atom::deactivate()
{
    assert(_actives > 0);
    --_actives;
}

void Atom::bondWith(Atom *neighbour, int depth)
{
    auto &currRelatives = neighbour->lattice() ? _crystalRelatives : _amorphRelatives;

    assert(_actives > 0);

    currRelatives.insert(neighbour);
    deactivate();
    if (depth > 0) neighbour->bondWith(this, 0);
}

void Atom::unbondFrom(Atom *neighbour, int depth)
{
    auto &currRelatives = neighbour->lattice() ? _crystalRelatives : _amorphRelatives;

    auto it = currRelatives.find(neighbour);
    assert(it != currRelatives.end());

    currRelatives.erase(it);
    activate();
    if (depth > 0) neighbour->unbondFrom(this, 0);
}

bool Atom::hasBondWith(Atom *neighbour) const
{
    return _crystalRelatives.find(neighbour) != _crystalRelatives.cend() ||
            _amorphRelatives.find(neighbour) != _amorphRelatives.cend();
}

Atom *Atom::amorphNeighbour()
{
    Atom *nbr = *_amorphRelatives.begin();
    assert(_amorphRelatives.count(nbr) == _amorphRelatives.size());
    return nbr;
}

Atom *Atom::firstCrystalNeighbour()
{
    if (!_crystalRelatives.empty())
    {
        return *_crystalRelatives.begin();
    }
    else
    {
        return nullptr;
    }
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
    assert(_cacheLattice);

    if (_lattice != _cacheLattice)
    {
        delete _cacheLattice;
    }

    _cacheLattice = _lattice;
    _lattice = nullptr;
}

void Atom::describe(ushort rType, BaseSpec *spec)
{
    const uint key = hash(rType, spec->type());

#ifdef PRINT
    debugPrint([&](std::ostream &os) {
        os << "describe " << this << std::dec;
        pos();
        os << " |" << type() << ", " << _prevType << "| role type: " << rType
           << ". spec type: " << spec->type() << ". key: " << key;
    });
#endif // PRINT

    _roles[rType].insert(spec->type());
    _specs.insert(std::pair<uint, BaseSpec *>(key, spec));
}

bool Atom::hasRole(ushort rType, ushort specType)
{
    const uint key = hash(rType, specType);
    return _specs.find(key) != _specs.end();
}

BaseSpec *Atom::specByRole(ushort rType, ushort specType)
{
    BaseSpec *result = nullptr;
    const uint key = hash(rType, specType);

#ifdef PRINT
    debugPrint([&](std::ostream &os) {
        os << "specByRole " << this << std::dec;
        pos();
        os << " |" << type() << ", " << _prevType << "| role type: " << rType
           << ". spec type: " << specType << ". key: " << key;
        auto er = _specs.equal_range(key);
        os << " -> distance: " << std::distance(er.first, er.second);
    });
#endif // PRINT

    auto its = _specs.equal_range(key);
    uint distance = std::distance(its.first, its.second);
    if (distance > 0)
    {
        assert(distance == 1);
        result = its.first->second;
    }

    return result;
}

void Atom::forget(ushort rType, BaseSpec *spec)
{
    const uint key = hash(rType, spec->type());

    auto its = _specs.equal_range(key);
    assert(std::distance(its.first, its.second) > 0);

    if (std::distance(its.first, its.second) == 1)
    {
        _roles.erase(rType);
    }

    while (its.first != its.second)
    {
        if (its.first->second == spec)
        {
            _specs.erase(its.first);
            break;
        }
        ++its.first;
    }

#ifdef PRINT
    debugPrint([&](std::ostream &os) {
        os << "forget " << this << std::dec;
        pos();
        os << " |" << type() << ", " << _prevType << "| role type: " << rType
                  << ". spec type: " << spec->type() << ". key: " << key;
    });
#endif // PRINT
}

void Atom::setSpecsUnvisited()
{
    for (auto &pr : _specs)
    {
        pr.second->setUnvisited();
    }
}

void Atom::removeUnsupportedSpecies()
{
    BaseSpec **specs = new BaseSpec*[_specs.size()]; // max possible size
    uint n = 0;

    for (auto &pr : _roles)
    {
        if (is(pr.first)) continue;

        for (ushort st : pr.second)
        {
            const uint key = hash(pr.first, st);
            auto its = _specs.equal_range(key);
            while (its.first != its.second)
            {
                specs[n++] = (its.first++)->second;
            }
        }
    }

    for (uint i = 0; i < n; ++i)
    {
        specs[i]->remove();
    }

    delete [] specs;
}

void Atom::findUnvisitedChildren()
{
    for (auto &pr : _specs)
    {
        BaseSpec *spec = pr.second;
        if (!spec->isVisited())
        {
            spec->findChildren();
        }
    }
}

void Atom::prepareToRemove()
{
    _prevType = _type;
    setType(NO_VALUE);
}

#ifdef PRINT
void Atom::info()
{
    debugPrintWoLock([&](std::ostream &os) {
        os << type() << " -> ";
        pos();

        os << " %% roles: ";
        for (const auto &pr : _roles)
        {
            os << pr.first;
            for (ushort st : pr.second)
            {
                os << " , " << st << " => " << hash(pr.first, st);
            }
            os << " | ";
        }

        os << " %% specs: ";
        for (const auto &pr : _specs)
        {
            os << pr.first << " -> " << pr.second << " # ";
        }
    }, false);
}

void Atom::pos()
{
    debugPrintWoLock([&](std::ostream &os) {
        if (lattice()) os << lattice()->coords();
        else os << "amorph";
    }, false);
}

#endif // PRINT


}
