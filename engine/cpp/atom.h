#ifndef ATOM_H
#define ATOM_H

#include <unordered_set>
#include <unordered_map>
#include "common.h"
#include "lattice.h"
#include "base_spec.h"

#include "lockable.h"

#include <assert.h>
//#include <iostream>

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
    std::unordered_multimap<ushort, BaseSpec *> _specs;

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

    virtual void bondWith(Atom *neighbour, int depth = 1);
    virtual void unbondFrom(Atom *neighbour, int depth = 1);
    virtual bool hasBondWith(Atom *neighbour) const;

    Lattice *lattice() const { return _lattice; }
    void setLattice(Crystal *crystal, const int3 &coords);
    void unsetLattice();

    void describe(ushort rType, BaseSpec *spec);
    bool hasRole(ushort atomType, ushort specType) const;
//    void forget(BaseSpec *spec);

protected:
    const std::unordered_multiset<Atom *> &neighbours() const { return _neighbours; }
    std::unordered_multiset<Atom *> &neighbours() { return _neighbours; }

    ushort actives() const { return _actives; }

    void setType(ushort type) { _type = type; }

private:
};

template <int VALENCE>
class ConcreteAtom : public Atom
{
public:
    using Atom::Atom;

//    void activate() override;
//    void bondWith(Atom *neighbour, int depth = 1) override;
};

//template <int VALENCE>
//void ConcreteAtom<VALENCE>::activate()
//{
//    assert(VALENCE > neighbours().size() + actives());
//    Atom::activate();
//}

//template <int VALENCE>
//void ConcreteAtom<VALENCE>::bondWith(Atom *neighbour, int depth)
//{
//    assert(VALENCE > neighbours().size());
////    if (VALENCE < neighbours().size() + actives())
////        std::cout << (unsigned long long)this << std::hex << " -> " << neighbours().size() << " : " << actives() << std::endl;
//    assert(VALENCE >= neighbours().size() + actives());
//    Atom::bondWith(neighbour, depth);
//}

}

#endif // ATOM_H
