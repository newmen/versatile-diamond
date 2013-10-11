#ifndef ATOM_H
#define ATOM_H

#include <unordered_set>
#include "common.h"

#include <assert.h>

namespace vd
{

class Crystal;
class Lattice;

class Atom
{
    uint _type;
    std::unordered_multiset<Atom *> _neighbours;
    Lattice *_lattice, *_cacheLattice;

public:
    Atom(uint type, Lattice *lattice);
    virtual ~Atom();

    virtual void findSpecs() = 0;

    virtual void bondWith(Atom *neighbour, int depth = 1);
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
