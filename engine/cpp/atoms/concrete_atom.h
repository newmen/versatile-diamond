#ifndef CONCRETE_ATOM_H
#define CONCRETE_ATOM_H

#include "atom.h"

#include <assert.h>
//#include <iostream>

namespace vd
{

template <int VALENCE>
class ConcreteAtom : public Atom
{
public:
//    using Atom::Atom;
    ConcreteAtom(ushort type, ushort actives, Lattice *lattice) : Atom(type, actives, lattice) {}

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

#endif // CONCRETE_ATOM_H
