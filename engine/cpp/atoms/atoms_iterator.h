#ifndef ATOMS_ITERATOR_H
#define ATOMS_ITERATOR_H

#include "atom.h"
#include "neighbours.h"

namespace vd
{

class AtomsIterator
{
public:
    template <class C>
    static C *crystalBy(Atom *atom);

    template <class C, class RL, class AL>
    static void eachNeighbour(Atom *anchor, C *crystal, const RL &relationsLambda, const AL &actionLambda);
};

template <class C>
C *AtomsIterator::crystalBy(Atom *atom)
{
    assert(atom->lattice());
    return static_cast<C *>(atom->lattice()->crystal());
}

template <class C, class RL, class AL>
void AtomsIterator::eachNeighbour(Atom *anchor, C *crystal, const RL &relationsLambda, const AL &actionLambda)
{
    auto neighbours = (crystal->*relationsLambda)(anchor);
    for (ushort i = 0; i < neighbours.QUANTITY; ++i)
    {
        Atom *neighbour = neighbours[i];
        if (neighbour && (i == 0 || neighbour->isVisited()))
        {
            actionLambda(neighbour);
        }
    }
}

}

#endif // ATOMS_ITERATOR_H
