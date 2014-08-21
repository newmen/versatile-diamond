#ifndef ATOM_H
#define ATOM_H

#include <algorithm>
#include <unordered_set>
#include <unordered_map>
#include "../species/base_spec.h"
#include "../tools/common.h"
#include "lattice.h"
#include "contained_species.h"

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

    Atom *amorphNeighbour() const;
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
    template <class S, ushort NUM> ContainedSpecies<S, NUM> specsByRole(ushort role);
    template <class S, class L> void eachSpecByRole(ushort role, const L &lambda);
    template <class S, class L> S *selectSpecByRole(ushort role, const L &lambda);

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
    void info(std::ostream &os);
    void pos(std::ostream &os);
#endif // PRINT

protected:
    Atom(ushort type, ushort actives, Lattice *lattice);

    void setType(ushort type) { _type = type; }

private:
    BaseSpec *specByRole(ushort sid, ushort role);

    float3 relativePosition() const;
    float3 correctAmorphPos() const;
    std::vector<const Atom *> goodCrystalRelatives() const;

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

template <class S>
S *Atom::specByRole(ushort role)
{
    BaseSpec *result = specByRole(S::ID, role);
    return static_cast<S *>(result);
}

template <class S, ushort NUM>
ContainedSpecies<S, NUM> Atom::specsByRole(ushort role)
{
    const uint key = hash(role, S::ID);
    auto range = _specs.equal_range(key);
    uint distance = std::distance(range.first, range.second);

    // there could be permutaion if assert failed,
    // and method should iterate "typles" of specs
    assert(distance <= NUM);

    S *specs[NUM] = { nullptr, nullptr };
    for (int i = 0; range.first != range.second; ++range.first, ++i)
    {
        specs[i] = static_cast<S *>(range.first->second);
    }
    return ContainedSpecies<S, NUM>(specs);
}

template <class S, class L>
void Atom::eachSpecByRole(ushort role, const L &lambda)
{
    const uint key = hash(role, S::ID);
    auto range = _specs.equal_range(key);
    for (; range.first != range.second; ++range.first)
    {
        BaseSpec *spec = range.first->second;
        lambda(static_cast<S *>(spec));
    }
}

template <class S, class L>
S *Atom::selectSpecByRole(ushort role, const L &lambda)
{
    S *result = nullptr;
    eachSpecByRole<S>(role, [&result, lambda](S *specie) {
        if (lambda(specie))
        {
            assert(!result);
            result = specie;
        }
    });
    return result;
}

}

#endif // ATOM_H
