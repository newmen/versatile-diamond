#ifndef ATOM_H
#define ATOM_H

#include <unordered_set>
#include "lattice.h"

namespace vd
{

class IAtom
{
    uint _type;
    std::unordered_multiset<Atom *> _neighbours;
    const Lattice *_lattice;
    bool _hasLattice;


public:
    IAtom(uint type, const Lattice *lattice = 0);
    virtual ~IAtom();

    virtual void bondWith(Atom *neighbour);
    virtual bool hasBondWith(Atom *neighbour) const;

protected:
    std::unordered_multiset<Atom *> &neighbours() { return _neighbours; }

private:
};

template <int VALENCE>
class Atom : public IAtom
{
public:
    using IAtom::IAtom;

    void bondWith(Atom *neighbour);
};

template <int VALENCE>
void Atom<VALENCE>::bondWith(Atom *neighbour)
{
    assert(VALENCE == neighbours().size());
    IAtom::bondWith(neighbour);
}

}

#endif // ATOM_H
