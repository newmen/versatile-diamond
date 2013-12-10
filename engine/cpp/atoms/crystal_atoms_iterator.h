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
#ifdef DEBUG
    assert(atom->lattice());
    auto dynamicResult = dynamic_cast<C *>(atom->lattice()->crystal());
    return dynamicResult;
#else
    return static_cast<C *>(atom->lattice()->crystal());
#endif // DEBUG
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
    for (ushort n = 0; n < NEIGHBOURS_NUM; ++n)
    {
        // TODO: need to separately use each anchor and correspond crystal?
        arrOfNeighbours[n] = (crystal->*relationsMethod)(anchors[n]);
    }

    Atom *neighbours[NEIGHBOURS_NUM];
    for (ushort i = 0; i < NeighboursType::QUANTITY; ++i)
    {
        bool allVisited = true;
        for (ushort n = 0; n < NEIGHBOURS_NUM; ++n)
        {
            Atom *neighbour = arrOfNeighbours[n][i];
            neighbours[n] = neighbour;

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
