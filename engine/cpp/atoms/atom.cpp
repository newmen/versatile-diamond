#include "atom.h"
#include <assert.h>
#include "../species/specific_spec.h"
#include "lattice.h"

#ifdef PRINT
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
    assert(_actives > 0);
    assert(_relatives.size() + _actives <= valence());

#ifdef DEBUG
    // latticed atom cannot be bonded twise with another latticed atom
    if (lattice() && neighbour->lattice())
    {
        assert(_relatives.find(neighbour) == _relatives.cend());
    }
#endif // DEBUG

    _relatives.insert(neighbour);
    deactivate();
    if (depth > 0) neighbour->bondWith(this, 0);
}

void Atom::unbondFrom(Atom *neighbour, int depth)
{
    auto it = _relatives.find(neighbour);
    assert(it != _relatives.cend());

    _relatives.erase(it);
    activate();
    if (depth > 0) neighbour->unbondFrom(this, 0);
}

bool Atom::hasBondWith(Atom *neighbour) const
{
    return _relatives.find(neighbour) != _relatives.cend();
}

Atom *Atom::amorphNeighbour()
{
    Atom *neighbour = nullptr;
    for (Atom *relative : _relatives)
    {
        if (!relative->lattice())
        {
            neighbour = relative;
            break;
        }
    }

    assert(neighbour);
#ifdef DEBUG
    for (Atom *relative : _relatives)
    {
        if (!relative->lattice() && relative != neighbour)
        {
            assert(false); // if has many unlatticed atoms
        }
    }
#endif // DEBUG

    return neighbour;
}

Atom *Atom::firstCrystalNeighbour()
{
    if (!_relatives.empty())
    {
        return *_relatives.begin();
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
        pos(os);
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
    return _specs.find(key) != _specs.cend();
}

void Atom::forget(ushort rType, BaseSpec *spec)
{
    const uint key = hash(rType, spec->type());

    auto range = _specs.equal_range(key);
    assert(std::distance(range.first, range.second) > 0);

    if (std::distance(range.first, range.second) == 1)
    {
        auto role = _roles.find(rType);
        assert(role->second.size() > 0);

        if (role->second.size() == 1)
        {
            _roles.erase(role);
        }
        else
        {
            role->second.erase(spec->type());
        }
    }

    while (range.first != range.second)
    {
        if (range.first->second == spec)
        {
            _specs.erase(range.first);
            break;
        }
        ++range.first;
    }

#ifdef PRINT
    debugPrint([&](std::ostream &os) {
        os << "forget " << this << std::dec;
        pos(os);
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
            auto range = _specs.equal_range(key);
            while (range.first != range.second)
            {
                specs[n++] = (range.first++)->second;
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
void Atom::info(std::ostream &os)
{
    os << type() << " -> ";
    pos(os);

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
}

void Atom::pos(std::ostream &os)
{
    if (lattice()) os << lattice()->coords();
    else os << "amorph";
}

#endif // PRINT

}
