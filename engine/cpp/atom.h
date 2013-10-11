#ifndef ATOM_H
#define ATOM_H

#include <unordered_set>
#include "common.h"
#include "lattice.h"

#include <assert.h>

namespace vd
{

class Atom
{
    uint _type;
    uint _actives;
    Lattice *_lattice, *_cacheLattice;
    std::unordered_multiset<Atom *> _neighbours;

public:
    Atom(uint type, uint actives, Lattice *lattice);
    virtual ~Atom();

    void activate();
    void deactivate();

    virtual void findSpecs() = 0;

    virtual void bondWith(Atom *neighbour, int depth = 1);
    virtual void unbondFrom(Atom *neighbour, int depth = 1);
    virtual bool hasBondWith(Atom *neighbour) const;

    Lattice *lattice() const { return _lattice; }
    void setLattice(Crystal *crystal, const int3 &coords);
    void unsetLattice();

protected:
    const std::unordered_multiset<Atom *> &neighbours() const { return _neighbours; }
    std::unordered_multiset<Atom *> &neighbours() { return _neighbours; }

private:
};

template <int VALENCE>
class ConcreteAtom : public Atom
{
public:
    using Atom::Atom;

    void bondWith(Atom *neighbour);
};

template <int VALENCE>
void ConcreteAtom<VALENCE>::bondWith(Atom *neighbour)
{
    assert(VALENCE != neighbours().size());
    Atom::bondWith(neighbour);
}

}

#endif // ATOM_H
