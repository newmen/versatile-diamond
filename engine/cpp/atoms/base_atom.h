#ifndef BASE_ATOM_H
#define BASE_ATOM_H

#include <algorithm>
#include <unordered_set>
#include "../tools/common.h"
#include "lattice.h"

namespace vd
{

const ushort NO_VALUE = (ushort)(-1);

template <class D, class C>
class BaseAtom
{
    ushort _type = NO_VALUE;
    ushort _actives;
    Lattice<C> *_lattice;

    typedef std::unordered_multiset<D *> Relatives;
    Relatives _relatives;

public:
    virtual ~BaseAtom();

    ushort type() const { return _type; }

    void activate() { ++_actives; }
    void deactivate()
    {
        assert(_actives > 0);
        --_actives;
    }

    void bondWith(D *neighbour, int depth = 1);
    template <class L> void eachNeighbour(const L &lambda) const;

    D *amorphNeighbour() const;
    D *firstCrystalNeighbour() const;
    ushort crystalNeighboursNum() const;

    Lattice<C> *lattice() const { return _lattice; }

    virtual const char *name() const = 0;

    virtual ushort valence() const = 0;
    virtual ushort hCount() const;
    virtual ushort actives() const { return _actives; }
    ushort bonds() const { return _relatives.size(); }

protected:
    BaseAtom(ushort type, ushort actives, Lattice<C> *lattice);

    const Relatives &relatives() const { return _relatives; }
    Relatives &relatives() { return _relatives; }

    void setType(ushort type) { _type = type; }
    void setLattice(Lattice<C> *lattice) { _lattice = lattice; }
};

//////////////////////////////////////////////////////////////////////////////////////

template <class D, class C>
BaseAtom<D, C>::BaseAtom(ushort type, ushort actives, Lattice<C> *lattice) :
    _type(type), _actives(actives), _lattice(lattice)
{
}

template <class D, class C>
BaseAtom<D, C>::~BaseAtom()
{
    delete _lattice;
}

template <class D, class C>
void BaseAtom<D, C>::bondWith(D *neighbour, int depth)
{
    assert(_actives > 0);
    assert(_relatives.size() + _actives <= valence());
    // TODO: there is bug for activation of *C=C%d<

#ifndef NDEBUG
    // latticed atom cannot be bonded twise with another latticed atom
    if (lattice() && neighbour->lattice())
    {
        assert(_relatives.find(neighbour) == _relatives.cend());
    }
#endif // NDEBUG

    _relatives.insert(neighbour);
    deactivate();
    if (depth > 0) neighbour->bondWith(static_cast<D *>(this), 0);
}

template <class D, class C>
template <class L>
void BaseAtom<D, C>::eachNeighbour(const L &lambda) const
{
    std::for_each(_relatives.cbegin(), _relatives.cend(), lambda);
}

template <class D, class C>
D *BaseAtom<D, C>::amorphNeighbour() const
{
    D *neighbour = nullptr;
    for (D *relative : _relatives)
    {
        if (!relative->lattice())
        {
            neighbour = relative;
            break;
        }
    }

    assert(neighbour);
#ifndef NDEBUG
    for (D *relative : _relatives)
    {
        if (!relative->lattice() && relative != neighbour)
        {
            assert(false); // if has many unlatticed atoms
        }
    }
#endif // NDEBUG

    return neighbour;
}

template <class D, class C>
D *BaseAtom<D, C>::firstCrystalNeighbour() const
{
    for (D *nbr : _relatives)
    {
        if (nbr->lattice()) return nbr;
    }

    return nullptr;
}

template <class D, class C>
ushort BaseAtom<D, C>::crystalNeighboursNum() const
{
    ushort result = lattice() ? 1 : 0;
    for (const D *nbr : _relatives)
    {
        if (nbr->lattice()) ++result;
    }

    return result;
}

template <class D, class C>
ushort BaseAtom<D, C>::hCount() const
{
    int hc = (int)valence() - actives() - bonds();
    assert(hc >= 0);
    return (ushort)hc;
}

}

#endif // BASE_ATOM_H
