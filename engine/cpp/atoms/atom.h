#ifndef ATOM_H
#define ATOM_H

#include <unordered_set>
#include <unordered_map>
#include <memory>

#include "../tools/common.h"
#include "../tools/lockable.h"

#include "lattice.h"
#include "role.h"

namespace vd
{

class BaseSpec;

class Atom : public Lockable
{
    ushort _type, _prevType = -1;
    ushort _actives;
    Lattice *_lattice, *_cacheLattice;
    std::unordered_multiset<Atom *> _neighbours;

    std::unordered_map<ushort, std::unordered_set<ushort>> _roles;
    std::unordered_multimap<uint, std::shared_ptr<BaseSpec>> _specs;

public:
    Atom(ushort type, ushort actives, Lattice *lattice);
    virtual ~Atom();

    ushort type() const { return _type; }
    ushort prevType() const { return _prevType; }

    virtual bool is(ushort typeOf) const = 0;
    virtual bool prevIs(ushort typeOf) const = 0;
    void changeType(ushort newType);

    virtual void activate();
    void deactivate();

    virtual void specifyType() = 0;
    virtual void findChildren() = 0;

    void bondWith(Atom *neighbour, int depth = 1);
    void unbondFrom(Atom *neighbour, int depth = 1);
    bool hasBondWith(Atom *neighbour) const;

    Lattice *lattice() const { return _lattice; }
    void setLattice(Crystal *crystal, const int3 &coords);
    void unsetLattice();

    void describe(ushort rType, std::shared_ptr<BaseSpec> &spec);
    bool hasRole(ushort rType, ushort specType);
    BaseSpec *specByRole(ushort rType, ushort specType);
//    void forget(BaseSpec *spec);

protected:
    const std::unordered_multiset<Atom *> &neighbours() const { return _neighbours; }
    std::unordered_multiset<Atom *> &neighbours() { return _neighbours; }

    ushort actives() const { return _actives; }

    void setType(ushort type) { _type = type; }

private:
    uint hash(ushort first, ushort second) const
    {
        uint at = first;
        return (at << 16) ^ second;
    }
};

}

#endif // ATOM_H
