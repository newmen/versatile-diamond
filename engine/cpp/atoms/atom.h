#ifndef ATOM_H
#define ATOM_H

#include <algorithm>
#include <unordered_set>
#include <unordered_map>
#include "../species/base_spec.h"
#include "../tools/common.h"
#include "lattice.h"

namespace vd
{

const ushort NO_VALUE = (ushort)(-1);

class Atom
{
    bool _visited = false;

    ushort _type, _prevType = NO_VALUE;
    ushort _actives;
    Lattice *_lattice, *_cacheLattice;

    std::unordered_multiset<Atom *> _relatives;

    std::unordered_map<ushort, std::unordered_set<ushort>> _roles;
    std::unordered_multimap<uint, BaseSpec *> _specs;

public:
    virtual ~Atom();

    void setVisited() { _visited = true; }
    void setUnvisited() { _visited = false; }
    bool isVisited() const { return _visited; }

    ushort type() const { return _type; }
    ushort prevType() const { return _prevType; }

    virtual bool is(ushort typeOf) const = 0;
    virtual bool prevIs(ushort typeOf) const = 0;
    virtual void specifyType() = 0;
    void changeType(ushort newType);

    void activate();
    void deactivate();

    void bondWith(Atom *neighbour, int depth = 1);
    void unbondFrom(Atom *neighbour, int depth = 1);
    bool hasBondWith(Atom *neighbour) const;

    template <class L> void eachNeighbour(const L &lambda) const;
    template <class L> void eachAmorphNeighbour(const L &lambda);

    Atom *firstCrystalNeighbour() const;
    ushort crystalNeighboursNum() const;

    Lattice *lattice() const { return _lattice; }
    void setLattice(Crystal *crystal, const int3 &coords);
    void unsetLattice();

    void describe(ushort role, BaseSpec *spec);
    void forget(ushort role, BaseSpec *spec);
    bool hasSpec(ushort role, BaseSpec *spec) const;

    bool hasRole(ushort sid, ushort role) const;
    bool checkAndFind(ushort sid, ushort role);
    template <class S> S *specByRole(ushort role);
    template <class S, class L> void eachSpecByRole(ushort role, const L &lambda);
    template <class S, class L> void eachSpecsPortionByRole(ushort role, ushort portion, const L &lambda);

    void setSpecsUnvisited();
    void findUnvisitedChildren();
    void removeUnsupportedSpecies();

    void prepareToRemove();

    virtual const char *name() const = 0;

    virtual ushort valence() const = 0;
    virtual ushort hCount() const;
    virtual ushort actives() const { return _actives; }
    ushort bonds() const { return _relatives.size(); }

    float3 realPosition() const;

#ifdef PRINT
    void info(IndentStream &os);
    void printRoles(IndentStream &os);
    void printSpecs(IndentStream &os);
    void pos(IndentStream &os);
#endif // PRINT

protected:
    Atom(ushort type, ushort actives, Lattice *lattice);

    void setType(ushort type) { _type = type; }

private:
    BaseSpec *specByRole(ushort sid, ushort role);

    float3 relativePosition() const;
    float3 correctAmorphPos() const;
    std::vector<const Atom *> goodCrystalRelatives() const;

    template <class S, class L>
    void combinations(ushort total, ushort n, S *specs, S *cache, const L &lambda);

    uint hash(ushort first, ushort second) const
    {
        uint at = first;
        return (at << 16) ^ second;
    }
};

//////////////////////////////////////////////////////////////////////////////////////

template <class L>
void Atom::eachNeighbour(const L &lambda) const
{
    std::for_each(_relatives.cbegin(), _relatives.cend(), lambda);
}

template <class L>
void Atom::eachAmorphNeighbour(const L &lambda)
{
    Atom **visited = new Atom *[_relatives.size()];
    ushort n = 0;
    for (Atom *neighbour : _relatives)
    {
        if (!neighbour->lattice())
        {
            // Skip multibonds
            bool hasSame = false;
            for (ushort i = 0; i < n; ++i)
            {
                if (visited[i] == neighbour)
                {
                    hasSame = true;
                    break;
                }
            }

            if (!hasSame)
            {
                lambda(neighbour);
                visited[n++] = neighbour;
            }
        }
    }
    delete [] visited;
}

template <class S>
S *Atom::specByRole(ushort role)
{
    BaseSpec *result = specByRole(S::ID, role);
    return static_cast<S *>(result);
}

template <class S, class L>
void Atom::eachSpecByRole(ushort role, const L &lambda)
{
    const uint key = hash(role, S::ID);
    auto range = _specs.equal_range(key);
    uint num = std::distance(range.first, range.second);
    if (num == 0) return;

#ifdef PRINT
    debugPrint([&](IndentStream &os) {
        os << "Atom::eachSpecByRole " << this << " " << std::dec;
        pos(os);
        os << " |" << _type << ", " << _prevType << "| role id: " << role
           << ". spec id: " << S::ID << ". key: " << key;
        os << " => total " << num << " specs:";

        for (auto it = range.first; it != range.second; ++it)
        {
            BaseSpec *spec = range.first->second;
            os << " <" << spec->type() << ">" << spec->name();
        }
    });
#endif // PRINT

    BaseSpec **specsDup = new BaseSpec *[num];
    for (uint i = 0; range.first != range.second; ++range.first, ++i)
    {
        specsDup[i] = range.first->second;
    }

    for (uint i = 0; i < num; ++i)
    {
        BaseSpec *spec = specsDup[i];
        assert(spec->type() == S::ID);
        lambda(static_cast<S *>(spec));
    }

    delete [] specsDup;
}

template <class S, class L>
void Atom::eachSpecsPortionByRole(ushort role, ushort portion, const L &lambda)
{
    const uint key = hash(role, S::ID);
    auto range = _specs.equal_range(key);
    uint num = std::distance(range.first, range.second);
    if (num < portion) return; // go out from iterator!

    S **specsDup = new S *[num];
    for (uint i = 0; range.first != range.second; ++range.first, ++i)
    {
        BaseSpec *spec = range.first->second;
        assert(spec->type() == S::ID);
        specsDup[i] = static_cast<S *>(spec);
    }

    if (num == portion)
    {
        lambda(specsDup);
    }
    else
    {
        S **cache = new S *[portion];
        combinations(num, portion, specsDup, cache, lambda);
        delete [] cache;
    }

    delete [] specsDup;
}

template <class S, class L>
void Atom::combinations(ushort total, ushort n, S *specs, S *cache, const L &lambda)
{
    for (ushort i = total; i >= n; --i)
    {
        cache[n - 1] = specs[i];
        if (n > 1)
        {
            combinations(i - 1, n - 1, specs, cache, lambda);
        }
        else
        {
            lambda(cache);
        }
    }
}

}

#endif // ATOM_H
