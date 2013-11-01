#ifndef ATOM_H
#define ATOM_H

#include <unordered_set>
#include <unordered_map>
#include "../tools/common.h"
#include "lattice.h"

#ifdef PARALLEL
#include "../tools/lockable.h"
#endif // PARALLEL

namespace vd
{

const ushort NO_VALUE = (ushort)(-1);

class BaseSpec;
class SpecificSpec;

#ifdef PARALLEL
class Atom : public Lockable
#endif // PARALLEL
#ifndef PARALLEL
class Atom
#endif // PARALLEL
{
    bool _visited = false;

    ushort _type, _prevType = NO_VALUE;
    ushort _actives;
    Lattice *_lattice, *_cacheLattice;

    // atoms bonded with current
    std::unordered_set<Atom *> _crystalRelatives;
    std::unordered_set<Atom *> _amorphRelatives;

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

    Lattice *lattice() const { return _lattice; }
    void setLattice(Crystal *crystal, const int3 &coords);
    void unsetLattice();

    void describe(ushort rType, BaseSpec *spec);
    bool hasRole(ushort rType, ushort specType);
    BaseSpec *specByRole(ushort rType, ushort specType);
    SpecificSpec *specificSpecByRole(ushort rType, ushort specType);
    void forget(ushort rType, BaseSpec *spec);

    void prepareToRemove();

#ifdef PRINT
    void info();
#endif // PRINT

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

}

#endif // ATOM_H
