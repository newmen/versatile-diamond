#ifndef ATOM_H
#define ATOM_H

#include <unordered_set>
#include <unordered_map>
#include "../tools/common.h"
#include "lattice.h"

#ifdef PRINT
#include <iostream>
#endif // PRINT

namespace vd
{

const ushort NO_VALUE = (ushort)(-1);

class BaseSpec;
class SpecificSpec;

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
    Atom(ushort type, ushort actives, Lattice *lattice);
    virtual ~Atom();

    void setVisited() { _visited = true; }
    void setUnvisited() { _visited = false; }
    bool isVisited() { return _visited; }

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

    Atom *amorphNeighbour();
    Atom *firstCrystalNeighbour();

    Lattice *lattice() const { return _lattice; }
    void setLattice(Crystal *crystal, const int3 &coords);
    void unsetLattice();

    void describe(ushort rType, BaseSpec *spec);
    void forget(ushort rType, BaseSpec *spec);
    bool hasRole(ushort rType, ushort specType);

    template <class S>
    S *specByRole(ushort rType, ushort specType);

    void setSpecsUnvisited();
    void findUnvisitedChildren();
    void removeUnsupportedSpecies();

    void prepareToRemove();

#ifdef PRINT
    void info(std::ostream &os);
    void pos(std::ostream &os);
#endif // PRINT

#ifdef DEBUG
    virtual ushort valence() const = 0;
#endif // DEBUG

protected:
    void setType(ushort type) { _type = type; }

#ifdef DEBUG
    ushort actives() const { return _actives; }
#endif // DEBUG

private:
    uint hash(ushort first, ushort second) const
    {
        uint at = first;
        return (at << 16) ^ second;
    }
};

template <class S>
S *Atom::specByRole(ushort rType, ushort specType)
{
    BaseSpec *result = nullptr;
    const uint key = hash(rType, specType);

#ifdef PRINT
    debugPrint([&](std::ostream &os) {
        os << "specByRole " << this << std::dec;
        pos(os);
        os << " |" << type() << ", " << _prevType << "| role type: " << rType
           << ". spec type: " << specType << ". key: " << key;
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

#ifdef DEBUG
    S *dynamicResult = nullptr;
    if (result)
    {
        dynamicResult = dynamic_cast<S *>(result);
        assert(dynamicResult);
    }
    return dynamicResult;
#else
    return static_cast<S *>(result);
#endif // DEBUG
}

}

#endif // ATOM_H
