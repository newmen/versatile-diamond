#ifndef CRYSTAL_ATOMS_ITERATOR_H
#define CRYSTAL_ATOMS_ITERATOR_H

#include "atom.h"
#include "neighbours.h"

namespace vd
{

class CrystalAtomsIterator
{
public:
    template <class C>
    static C *crystalBy(Atom *atom);

    template <class C, class RL, class AL>
    static void eachNeighbour(Atom *anchor, C *crystal,
                              const RL &relationsLambda, const AL &actionLambda);

    template <class C, class RL, class AL>
    static void eachNeighbours(Atom **anchors, ushort n, C *crystal,
                               const RL &relationsLambda, const AL &actionLambda);
};

template <class C>
C *CrystalAtomsIterator::crystalBy(Atom *atom)
{
    assert(atom->lattice());
    return static_cast<C *>(atom->lattice()->crystal());
}

template <class C, class RL, class AL>
void CrystalAtomsIterator::eachNeighbour(Atom *anchor, C *crystal,
                                  const RL &relationsLambda, const AL &actionLambda)
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

template <class C, class RL, class AL>
void CrystalAtomsIterator::eachNeighbours(Atom **anchors, ushort n, C *crystal,
                                   const RL &relationsLambda, const AL &actionLambda)
{
    // TODO: so many heap memory allocations...
    // maybe need to pass the "n" as template argument for allocating memory in stack

    auto arrOfNeighbours = new decltype((crystal->*relationsLambda)(nullptr))[n];
    for (ushort k = 0; k < n; ++k)
    {
        arrOfNeighbours[k] = std::move((crystal->*relationsLambda)(anchors[k]));
    }

    Atom **neighbours = new Atom *[n];
    for (ushort i = 0; i < arrOfNeighbours[0].QUANTITY; ++i)
    {
        bool allInstanced = true;
        bool allVisited = true;
        for (ushort k = 0; k < n; ++k)
        {
            Atom *neighbour = arrOfNeighbours[i][k];
            neighbours[k] = neighbour;

            allInstanced = allInstanced && (neighbour != nullptr);
            allVisited = allVisited && neighbour->isVisited();
        }

        if (allInstanced && (i == 0 || allVisited))
        {
            actionLambda(neighbours);
        }
    }

    delete [] neighbours;
    delete [] arrOfNeighbours;
}

}

#endif // CRYSTAL_ATOMS_ITERATOR_H
