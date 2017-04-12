#ifndef ATOM_H
#define ATOM_H

#include <unordered_map>
#include "../phases/crystal.h"
#include "../species/base_spec.h"
#include "base_atom.h"

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

    void eraseFromCrystal();

    void describe(ushort role, BaseSpec *spec);
    void forget(ushort role, BaseSpec *spec);
    bool hasSpec(ushort role, BaseSpec *spec) const;

    ushort amorphNeighboursNum() const;
    ushort doubleNeighboursNum() const;
    ushort tripleNeighboursNum() const;

    bool hasRole(ushort sid, ushort role) const;
    bool checkAndFind(ushort sid, ushort role);
    template <class S> S *specByRole(ushort role);
    template <class S, class L> void eachSpecByRole(ushort role, const L &lambda);
    template <class S, class L> void eachSpecsPortionByRole(ushort role, ushort portion, const L &lambda);

    void setSpecsUnvisited();
    void findUnvisitedChildren();
    void removeUnsupportedSpecies();

    void prepareToRemove();

#if defined(PRINT) || defined(ATOM_PRINT)
    void info(IndentStream &os);
    void printRoles(IndentStream &os);
    void printSpecs(IndentStream &os);
    void pos(IndentStream &os);
#endif // PRINT || ATOM_PRINT

protected:
    Atom(ushort type, ushort actives, OriginalLattice *lattice);

private:
    Atom(const Atom &) = delete;
    Atom(Atom &&) = delete;
    Atom &operator = (const Atom &) = delete;
    Atom &operator = (Atom &&) = delete;

    BaseSpec *specByRole(ushort sid, ushort role);

    template <class S, class L>
    void combinations(ushort total, ushort n, S *specs, S *cache, const L &lambda);

    uint hash(ushort first, ushort second) const
    {
        uint at = first;
        return (at << 16) ^ second;
    }

    typedef std::unordered_map<const Atom *, ushort> Counter;
    Counter sumNeighbours() const;
    ushort countBonds(ushort arity) const;
};

//////////////////////////////////////////////////////////////////////////////////////

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

#if defined(PRINT) || defined(ATOM_PRINT)
    debugPrint([&](IndentStream &os) {
        os << "Atom::eachSpecByRole " << this << " " << std::dec;
        pos(os);
        os << " |" << type() << ", " << _prevType << "| role id: " << role
           << ". spec id: " << S::ID << ". key: " << key;
        os << " => total " << num << " specs:";

        for (auto it = range.first; it != range.second; ++it)
        {
            BaseSpec *spec = range.first->second;
            os << " <" << spec->type() << ">" << spec->name();
        }
    });
#endif // PRINT || ATOM_PRINT

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
