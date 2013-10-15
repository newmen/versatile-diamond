#ifndef ATOM_H
#define ATOM_H

#include <unordered_set>
#include "common.h"
#include "lattice.h"

#include <assert.h>
#include <base_spec.h>

namespace vd
{

class BaseSpec;

class Atom
{
    uint _type, _prevType = -1;
    uint _actives;
    Lattice *_lattice, *_cacheLattice;
    std::unordered_multiset<Atom *> _neighbours;

//    std::unordered_set<BaseSpec *> _specs;

public:
    Atom(uint type, uint actives, Lattice *lattice);
    virtual ~Atom();

    virtual bool is(uint typeOf) const = 0;
    virtual bool prevIs(uint typeOf) const = 0;
    void changeType(uint newType);

    virtual void activate();
    void deactivate();

    virtual void specifyType() = 0;
    virtual void findSpecs() = 0;

    virtual void bondWith(Atom *neighbour, int depth = 1);
    virtual void unbondFrom(Atom *neighbour, int depth = 1);
    virtual bool hasBondWith(Atom *neighbour) const;

    Lattice *lattice() const { return _lattice; }
    void setLattice(Crystal *crystal, const int3 &coords);
    void unsetLattice();

//    void describe(BaseSpec *spec);
//    void forget(BaseSpec *spec);

protected:
    const std::unordered_multiset<Atom *> &neighbours() const { return _neighbours; }
    std::unordered_multiset<Atom *> &neighbours() { return _neighbours; }

    uint actives() const { return _actives; }

    uint type() const { return _type; }
    uint prevType() const { return _prevType; }
    void setType(uint type) { _type = type; }

private:
};

template <int VALENCE>
class ConcreteAtom : public Atom
{
public:
    using Atom::Atom;

    void activate() override;
    void bondWith(Atom *neighbour, int depth = 1) override;
};

template <int VALENCE>
void ConcreteAtom<VALENCE>::activate()
{
    assert(VALENCE > neighbours().size() + actives());
    Atom::activate();
}

template <int VALENCE>
void ConcreteAtom<VALENCE>::bondWith(Atom *neighbour, int depth)
{
    assert(VALENCE > neighbours().size());
    assert(VALENCE >= neighbours().size() + actives());
    Atom::bondWith(neighbour, depth);
}

}

#endif // ATOM_H
