#include "atom.h"
#include <algorithm>
#include "lattice.h"

namespace vd
{

Atom::Atom(ushort type, ushort actives, OriginalLattice *lattice) :
    BaseAtom(type, actives, lattice), _cacheLattice(lattice)
{
}

Atom::~Atom()
{
    if (!lattice())
    {
        delete _cacheLattice;
    }
}

void Atom::changeType(ushort newType)
{
    _prevType = type();
    setType(newType);
    specifyType();
}

void Atom::unbondFrom(Atom *neighbour, int depth)
{
    auto it = relatives().find(neighbour);
    assert(it != relatives().cend());

    relatives().erase(it);
    activate();
    if (depth > 0) neighbour->unbondFrom(this, 0);
}

bool Atom::hasBondWith(Atom *neighbour) const
{
    return relatives().find(neighbour) != relatives().cend();
}

void Atom::setLattice(Crystal *crystal, const int3 &coords)
{
    assert(crystal);
    assert(!lattice());

    if (_cacheLattice && _cacheLattice->crystal() == crystal)
    {
        _cacheLattice->updateCoords(coords);
    }
    else
    {
        delete _cacheLattice;
        _cacheLattice = new Lattice<Crystal>(crystal, coords);
    }

    BaseAtom::setLattice(_cacheLattice);
}

void Atom::unsetLattice()
{
    assert(lattice());
    assert(_cacheLattice);

    if (lattice() != _cacheLattice)
    {
        delete _cacheLattice;
    }

    _cacheLattice = lattice();
    BaseAtom::setLattice(nullptr);
}

void Atom::describe(ushort role, BaseSpec *spec)
{
    assert(is(role));

    const uint key = hash(role, spec->type());

#ifdef PRINT
    debugPrint([&](std::ostream &os) {
        os << "describe " << this << " " << std::dec;
        pos(os);
        os << " " << spec->name();
        os << " |" << type() << ", " << _prevType << "| role type: " << role
           << ". spec type: " << spec->type() << ". key: " << key;
    });
#endif // PRINT

    _roles[role].insert(spec->type());
    _specs.insert(std::pair<uint, BaseSpec *>(key, spec));
}

void Atom::forget(ushort role, BaseSpec *spec)
{
    const uint key = hash(role, spec->type());

    auto range = _specs.equal_range(key);
    assert(std::distance(range.first, range.second) > 0);

    if (std::distance(range.first, range.second) == 1)
    {
        auto pr = _roles.find(role);
        assert(pr->second.size() > 0);

        if (pr->second.size() == 1)
        {
            _roles.erase(pr);
        }
        else
        {
            pr->second.erase(spec->type());
        }
    }

    for (; range.first != range.second; ++range.first)
    {
        if (range.first->second == spec)
        {
            _specs.erase(range.first);
            break;
        }
    }

#ifdef PRINT
    debugPrint([&](std::ostream &os) {
        os << "forget " << this << " " << std::dec;
        pos(os);
        os << " " << spec->name();
        os << " |" << type() << ", " << _prevType << "| role type: " << role
                  << ". spec type: " << spec->type() << ". key: " << key;
    });
#endif // PRINT
}

bool Atom::hasSpec(ushort role, BaseSpec *spec) const
{
    const uint key = hash(role, spec->type());

    auto range = _specs.equal_range(key);
    for (; range.first != range.second; ++range.first)
    {
        if (range.first->second == spec)
        {
            return true;
        }
    }

    return false;
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
    if (_specs.size() == 0) return;

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
        pr.second->findChildren();
    }
}

void Atom::prepareToRemove()
{
    _prevType = type();
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

bool Atom::hasRole(ushort sid, ushort role) const
{
    const uint key = hash(role, sid);
    return _specs.find(key) != _specs.cend();
}

bool Atom::checkAndFind(ushort sid, ushort role)
{
    BaseSpec *spec = specByRole(sid, role);
    if (spec)
    {
        spec->findChildren();
    }

    return spec != nullptr;
}

BaseSpec *Atom::specByRole(ushort sid, ushort role)
{
    BaseSpec *result = nullptr;
    const uint key = hash(role, sid);

#ifdef PRINT
    debugPrint([&](std::ostream &os) {
        os << "specByRole " << this << std::dec;
        pos(os);
        os << " |" << type() << ", " << _prevType << "| role type: " << role
           << ". spec type: " << sid << ". key: " << key;
        auto range = _specs.equal_range(key);
        os << " -> distance: " << std::distance(range.first, range.second);
    });
#endif // PRINT

    auto range = _specs.equal_range(key);
    uint distance = std::distance(range.first, range.second);
    if (distance > 0)
    {
        assert(distance == 1);
        result = range.first->second;
    }

    return result;
}

}
