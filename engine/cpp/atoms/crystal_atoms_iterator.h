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
    static void eachNeighbour(Atom *anchor, C *crystal, const RL &relationsMethod, const AL &actionLambda);

    template <ushort NEIGHBOURS_NUM, class C, class RL, class AL>
    static void eachNeighbours(Atom **anchors, C *crystal, const RL &relationsMethod, const AL &actionLambda);
};

template <class C>
C *CrystalAtomsIterator::crystalBy(Atom *atom)
{
    assert(atom->lattice());
    return static_cast<C *>(atom->lattice()->crystal());
}

template <class C, class RL, class AL>
void CrystalAtomsIterator::eachNeighbour(Atom *anchor, C *crystal, const RL &relationsMethod, const AL &actionLambda)
{
    eachNeighbours<1>(&anchor, crystal, relationsMethod, [&actionLambda](Atom **neighbours) {
        actionLambda(neighbours[0]);
    });
}

template <ushort NEIGHBOURS_NUM, class C, class RL, class AL>
void CrystalAtomsIterator::eachNeighbours(Atom **anchors, C *crystal, const RL &relationsMethod, const AL &actionLambda)
{
    typedef decltype((crystal->*relationsMethod)(nullptr)) NeighboursType;

    NeighboursType arrOfNeighbours[NEIGHBOURS_NUM];
    for (ushort k = 0; k < NEIGHBOURS_NUM; ++k)
    {
        arrOfNeighbours[k] = (crystal->*relationsMethod)(anchors[k]);
    }

    Atom *neighbours[NEIGHBOURS_NUM];
    for (ushort i = 0; i < NeighboursType::QUANTITY; ++i)
    {
        bool allVisited = true;
        for (ushort k = 0; k < NEIGHBOURS_NUM; ++k)
        {
            Atom *neighbour = arrOfNeighbours[i][k];
            neighbours[k] = neighbour;

            if (!neighbour)
            {
                goto next_main_iteration;
            }

            allVisited &= neighbour->isVisited();
        }

        if (i == 0 || allVisited)
        {
            actionLambda(neighbours);
        }

        next_main_iteration :;
    }
}

}

#endif // CRYSTAL_ATOMS_ITERATOR_H
