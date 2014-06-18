// Provides methods for get an atom neighbours through diamond crystall lattice.
// This file should be used together with diamond_crystal_properties.h and
// diamond.rb lattice describer.

#ifndef DIAMOND_RELATIONS_H
#define DIAMOND_RELATIONS_H

#include <algorithm>
#include <atoms/neighbours.h>
using namespace vd;

template <class B>
class DiamondRelations : public B
{
public:
    typedef Neighbours<2> TN;
    typedef TN (DiamondRelations<B>::*RelationsMethod)(const Atom *) const;

    TN front_110(const Atom *atom) const;
    TN cross_110(const Atom *atom) const;
    TN front_100(const Atom *atom) const;
    TN cross_100(const Atom *atom) const;

    static int3 front_110_at(const Atom *first, const Atom *second);

protected:
    template <class... Args> DiamondRelations(Args... args) : B(args...) {}
};

//////////////////////////////////////////////////////////////////////////////////////

template <class B>
typename DiamondRelations<B>::TN DiamondRelations<B>::front_110(const Atom *atom) const
{
    assert(atom->lattice());
    const int3 &coords = atom->lattice()->coords();

    Atom *twoAtoms[2];
    if (coords.z % 2 == 0)
    {
        twoAtoms[0] = this->atom(int3(coords.x - 1, coords.y, coords.z + 1));
    }
    else
    {
        twoAtoms[0] = this->atom(int3(coords.x, coords.y - 1, coords.z + 1));
    }
    twoAtoms[1] = this->atom(int3(coords.x, coords.y, coords.z + 1));

    return TN(twoAtoms);
}

template <class B>
typename DiamondRelations<B>::TN DiamondRelations<B>::cross_110(const Atom *atom) const
{
    assert(atom->lattice());
    const int3 &coords = atom->lattice()->coords();

    Atom *twoAtoms[2];

    twoAtoms[0] = this->atom(int3(coords.x, coords.y, coords.z - 1));
    if (coords.z % 2 == 0)
    {
        twoAtoms[1] = this->atom(int3(coords.x, coords.y + 1, coords.z - 1));
    }
    else
    {
        twoAtoms[1] = this->atom(int3(coords.x + 1, coords.y, coords.z - 1));
    }

    return TN(twoAtoms);
}

template <class B>
typename DiamondRelations<B>::TN DiamondRelations<B>::front_100(const Atom *atom) const
{
    assert(atom->lattice());
    const int3 &coords = atom->lattice()->coords();

    Atom *twoAtoms[2];
    if (coords.z % 2 == 0)
    {
        twoAtoms[0] = this->atom(int3(coords.x - 1, coords.y, coords.z));
        twoAtoms[1] = this->atom(int3(coords.x + 1, coords.y, coords.z));
    }
    else
    {
        twoAtoms[0] = this->atom(int3(coords.x, coords.y - 1, coords.z));
        twoAtoms[1] = this->atom(int3(coords.x, coords.y + 1, coords.z));
    }
    return TN(twoAtoms);
}

template <class B>
typename DiamondRelations<B>::TN DiamondRelations<B>::cross_100(const Atom *atom) const
{
    assert(atom->lattice());
    const int3 &coords = atom->lattice()->coords();

    Atom *twoAtoms[2];
    if (coords.z % 2 == 0)
    {
        twoAtoms[0] = this->atom(int3(coords.x, coords.y - 1, coords.z));
        twoAtoms[1] = this->atom(int3(coords.x, coords.y + 1, coords.z));
    }
    else
    {
        twoAtoms[0] = this->atom(int3(coords.x - 1, coords.y, coords.z));
        twoAtoms[1] = this->atom(int3(coords.x + 1, coords.y, coords.z));
    }
    return TN(twoAtoms);
}

template <class B>
int3 DiamondRelations<B>::front_110_at(const Atom *first, const Atom *second)
{
    assert(first->lattice());
    assert(second->lattice());

    const int3 &a = first->lattice()->coords();
    const int3 &b = second->lattice()->coords();
    assert(a.z == b.z);

    if (a.z % 2 == 0)
    {
        assert(a.x != b.x);
        assert(a.y == b.y);
        if (std::abs(a.x - b.x) == 1)
        {
            return int3(std::min(a.x, b.x), a.y, a.z + 1);
        }
        else
        {
            assert(a.x == 0 || b.x == 0);
            return int3(std::max(a.x, b.x), a.y, a.z + 1);
        }
    }
    else
    {
        assert(a.x == b.x);
        assert(a.y != b.y);
        if (std::abs(a.y - b.y) == 1)
        {
            return int3(a.x, std::min(a.y, b.y), a.z + 1);
        }
        else
        {
            assert(a.y == 0 || b.y == 0);
            return int3(a.x, std::max(a.y, b.y), a.z + 1);
        }
    }
}

#endif // DIAMOND_RELATIONS_H
