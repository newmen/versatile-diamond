#ifndef ATOM_H
#define ATOM_H

#include <algorithm>
#include <unordered_set>
#include <unordered_map>
#include "../tools/common.h"
#include "lattice.h"

namespace vd
{

const ushort NO_VALUE = (ushort)(-1);

class BaseSpec;

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

    template <class L>
    void eachNeighbour(const L &lambda) const;

    Atom *amorphNeighbour() const;
    Atom *firstCrystalNeighbour() const;

    Lattice *lattice() const { return _lattice; }
    void setLattice(Crystal *crystal, const int3 &coords);
    void unsetLattice();

    void describe(ushort role, BaseSpec *spec);
    void forget(ushort role, BaseSpec *spec);
    bool hasSpec(ushort role, BaseSpec *spec) const;

    template <class S>
    bool hasRole(ushort role) const;

    template <class S>
    S *specByRole(ushort role);

    template <class S, class L>
    S *findSpecByRole(ushort role, const L &lambda);

    void setSpecsUnvisited();
    void findUnvisitedChildren();
    void removeUnsupportedSpecies();

    void prepareToRemove();

    virtual const char *name() const = 0;

    virtual ushort valence() const = 0;
    ushort bonds() const { return _relatives.size(); }
    ushort actives() const { return _actives; }
    ushort hCount() const;

#ifdef PRINT
    void info(std::ostream &os);
    void pos(std::ostream &os);
#endif // PRINT

protected:
    Atom(ushort type, ushort actives, Lattice *lattice);

    void setType(ushort type) { _type = type; }

private:
    bool hasRole(ushort sid, ushort role) const;
    BaseSpec *specByRole(ushort sid, ushort role);

    uint hash(ushort first, ushort second) const
    {
        uint at = first;
        return (at << 16) ^ second;
    }
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class L>
void Atom::eachNeighbour(const L &lambda) const
{
    std::for_each(_relatives.cbegin(), _relatives.cend(), lambda);
}

template <class S>
bool Atom::hasRole(ushort role) const
{
    return hasRole(S::ID, role);
}

template <class S>
S *Atom::specByRole(ushort role)
{
    BaseSpec *result = specByRole(S::ID, role);
    return static_cast<S *>(result);
}

template <class S, class L>
S *Atom::findSpecByRole(ushort role, const L &lambda)
{
    BaseSpec *result = nullptr;
    const uint key = hash(role, S::ID);

    auto range = _specs.equal_range(key);
    for (; range.first != range.second; ++range.first)
    {
        BaseSpec *spec = range.first->second;
        if (lambda(spec))
        {
            result = spec;
            break;
        }
    }
    return static_cast<S *>(result);
}

}

#endif // ATOM_H
