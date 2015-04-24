#ifndef ATOM_H
#define ATOM_H

#include <unordered_map>
#include "../phases/crystal.h"
#include "../species/base_spec.h"
#include "base_atom.h"
#include "contained_species.h"

namespace vd
{

class Atom : public BaseAtom<Atom, Crystal>
{
protected:
    typedef Lattice<Crystal> OriginalLattice;

private:
    bool _visited = false;

    ushort _prevType = NO_VALUE;
    OriginalLattice *_cacheLattice;

    std::unordered_map<ushort, std::unordered_set<ushort>> _roles;
    std::unordered_multimap<uint, BaseSpec *> _specs;

public:
    virtual ~Atom();

    void setVisited() { _visited = true; }
    void setUnvisited() { _visited = false; }
    bool isVisited() const { return _visited; }

    ushort prevType() const { return _prevType; }

    virtual bool is(ushort typeOf) const = 0;
    virtual bool prevIs(ushort typeOf) const = 0;
    virtual void specifyType() = 0;
    void changeType(ushort newType);

    void unbondFrom(Atom *neighbour, int depth = 1);
    bool hasBondWith(Atom *neighbour) const;

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

    void setSpecsUnvisited();
    void findUnvisitedChildren();
    void removeUnsupportedSpecies();

    void prepareToRemove();

#ifdef PRINT
    void info(std::ostream &os);
    void pos(std::ostream &os);
#endif // PRINT

protected:
    Atom(ushort type, ushort actives, OriginalLattice *lattice);

private:
    Atom(const Atom &) = delete;
    Atom(Atom &&) = delete;
    Atom &operator = (const Atom &) = delete;
    Atom &operator = (Atom &&) = delete;

    BaseSpec *specByRole(ushort sid, ushort role);

    uint hash(ushort first, ushort second) const
    {
        uint at = first;
        return (at << 16) ^ second;
    }
};

//////////////////////////////////////////////////////////////////////////////////////

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

}

#endif // ATOM_H
