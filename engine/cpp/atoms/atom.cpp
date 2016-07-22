#include "atom.h"
#include <algorithm>
#include "lattice.h"

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
    // TODO: there is bug for activation of *C=C%d<

#ifndef NDEBUG
    // latticed atom cannot be bonded twise with another latticed atom
    if (lattice() && neighbour->lattice())
    {
        assert(_relatives.find(neighbour) == _relatives.cend());
    }
#endif // NDEBUG

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

Atom *Atom::firstCrystalNeighbour() const
{
    for (Atom *nbr : _relatives)
    {
        if (nbr->lattice()) return nbr;
    }

    return nullptr;
}

ushort Atom::crystalNeighboursNum() const
{
    ushort result = lattice() ? 1 : 0;
    for (const Atom *nbr : _relatives)
    {
        if (nbr->lattice()) ++result;
    }

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
    assert(_cacheLattice);

    _cacheLattice = _lattice;
    _lattice = nullptr;
}

void Atom::eraseFromCrystal()
{
    assert(lattice());
    lattice()->crystal()->erase(this);
}

void Atom::describe(ushort role, BaseSpec *spec)
{
    assert(is(role));

    const uint type = spec->type();
    const uint key = hash(role, type);

#ifdef PRINT
    debugPrint([&](IndentStream &os) {
        os << "Atom::describe " << this << " " << std::dec;
        pos(os);
        os << " " << spec->name();
        os << " |" << _type << ", " << _prevType << "| role type: " << role
           << ". spec type: " << type << ". key: " << key;
    });
#endif // PRINT

    _roles[role].insert(type);
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
    debugPrint([&](IndentStream &os) {
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
    _prevType = _type;
    setType(NO_VALUE);
}

ushort Atom::hCount() const
{
    int hc = (int)valence() - actives() - bonds();
    assert(hc >= 0);
    return (ushort)hc;
}

float3 Atom::realPosition() const
{
    if (lattice())
    {
        return relativePosition() + lattice()->crystal()->correct(this);
    }
    else
    {
        return relativePosition();
    }
}

float3 Atom::relativePosition() const
{
    if (lattice())
    {
        return lattice()->crystal()->translate(lattice()->coords());
    }
    else
    {
        return correctAmorphPos();
    }
}

float3 Atom::correctAmorphPos() const
{
    const float amorphBondLength = 1.7;

    float3 position;
    auto goodRelatives = goodCrystalRelatives();
    uint counter = goodRelatives.size();

    for (const Atom *nbr : goodRelatives)
    {
        position += nbr->relativePosition(); // should be used realPosition() if correct behavior of additionHeight() for case when counter == 1;
    }

    if (counter == 1)
    {
        // TODO: targets to another atoms of...
        position.z += amorphBondLength;
    }
    else if (counter == 2)
    {
        position /= 2;

        const float3 frl = goodRelatives[0]->relativePosition();
        const float3 srl = goodRelatives[1]->relativePosition();

        double l = frl.length(srl);
        assert(l > 0);
        double halfL = l * 0.5;
        assert(halfL < amorphBondLength);

        double diffZ = frl.z - srl.z;
        double smallXY = amorphBondLength * diffZ / l;
        double angleXY = std::atan((frl.y - srl.y) / (frl.x - srl.x));
        position.x += smallXY / std::cos(angleXY);
        position.y += smallXY / std::sin(angleXY);

        double tiltedH = std::sqrt(amorphBondLength * amorphBondLength - halfL * halfL);
        double angleH = (std::abs(diffZ) < 1e-3) ? 0 : std::asin(l / diffZ);
        position.z += tiltedH / std::cos(angleH);
    }
    else
    {
        assert(goodRelatives.size() > 2);

        const float3 &frl = goodRelatives[0]->relativePosition();
        const float3 &srl = goodRelatives[1]->relativePosition();
        const float3 &trl = goodRelatives[2]->relativePosition();

        double a = frl.length(srl);
        double b = frl.length(trl);
        double c = srl.length(trl);
        double p = (a + b + c) * 0.5;

        double r = 0.25 * a * b * c / std::sqrt(p * (p - a) * (p - b) * (p - c));
        assert(r < amorphBondLength);

        double tiltedH = std::sqrt(amorphBondLength * amorphBondLength - r * r);
        // ...
        assert(false); // there should be juicy code
    }

    return position;
}

std::vector<const Atom *> Atom::goodCrystalRelatives() const
{
    assert(!lattice());

    const ushort crystNNs = crystalNeighboursNum();
    const int3 *crystalCrds = nullptr;

    std::vector<const Atom *> result;
    for (const Atom *nbr : _relatives)
    {
        if (!crystalCrds && nbr->lattice())
        {
            crystalCrds = &nbr->lattice()->coords();
        }
        else if (nbr->lattice())
        {
            int3 diff = *crystalCrds - nbr->lattice()->coords();
            if (!diff.isUnit()) continue;
        }

        ushort nbrCrystNNs = nbr->crystalNeighboursNum();
        if (crystNNs < nbrCrystNNs || (crystNNs == nbrCrystNNs && bonds() < nbr->bonds()))
        {
            if (std::find(result.cbegin(), result.cend(), nbr) == result.cend())
            {
                result.push_back(nbr);
            }
        }
    }

    return result;
}

#ifdef PRINT
void Atom::info(IndentStream &os)
{
    os << type() << " -> ";
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
    BaseSpec *result = nullptr;
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
        result = range.first->second;
    }

    return result;
}

}
