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

void Atom::eraseFromCrystal()
{
    assert(lattice());
    lattice()->crystal()->erase(this);
}

void Atom::describe(ushort role, BaseSpec *spec)
{
    assert(is(role));

    const ushort specType = spec->type();
    const uint key = hash(role, specType);

#ifdef PRINT
    debugPrint([&](IndentStream &os) {
        os << "Atom::describe " << this << " " << std::dec;
        pos(os);
        os << " " << spec->name();
        os << " |" << type() << ", " << _prevType << "| role type: " << role
           << ". spec type: " << specType << ". key: " << key;
    });
#endif // PRINT

    _roles[role].insert(specType);
    _specs.insert(std::pair<uint, BaseSpec *>(key, spec));
}

void Atom::forget(ushort role, BaseSpec *spec)
{
    const ushort specType = spec->type();
    const uint key = hash(role, specType);

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
            pr->second.erase(specType);
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
    debugPrint([&](IndentStream &os) {
        os << "forget " << this << " " << std::dec;
        pos(os);
        os << " " << spec->name();
        os << " |" << type() << ", " << _prevType << "| role type: " << role
                  << ". spec type: " << specType << ". key: " << key;
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
    uint num = _specs.size();
    if (num == 0) return;

    BaseSpec **specs = new BaseSpec*[num]; // max possible size
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
void Atom::info(IndentStream &os)
{
    os << type() << " [" << this << "] -> ";
    pos(os);

    printRoles(os);
    printSpecs(os);
}

void Atom::printRoles(IndentStream &os)
{
    IndentStream sub = indentStream(os);
    sub << "%% roles: ";
    bool isFirst = true;
    for (const auto &pr : _roles)
    {
        if (!isFirst)
        {
            sub << " | ";
        }

        sub << pr.first << " >> ";
        int prevSt = -1;
        for (ushort st : pr.second)
        {
            if (st == prevSt)
            {
                sub << " + ";
            }
            else
            {
                if (prevSt != -1)
                {
                    sub << ", ";
                }
                sub << st << " => ";
            }
            sub << hash(pr.first, st);
            prevSt = st;
        }

        isFirst = false;
    }
}

void Atom::printSpecs(IndentStream &os)
{
    IndentStream sub = indentStream(os);
    sub << "%% specs: ";
    bool isFirst = true;
    for (const auto &pr : _specs)
    {
        if (!isFirst)
        {
            sub << " # ";
        }

        sub << pr.first << " -> " << pr.second;
        isFirst = false;
    }
}

void Atom::pos(IndentStream &os)
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
    const uint key = hash(role, sid);

#ifdef PRINT
    debugPrint([&](IndentStream &os) {
        os << "Atom::specByRole " << this << std::dec;
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
        return range.first->second;
    }
    else
    {
        return nullptr;
    }
}

}
