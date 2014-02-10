#ifndef CRYSTAL_ATOMS_ITERATOR_H
#define CRYSTAL_ATOMS_ITERATOR_H

#include "../atoms/atom.h"
#include "../atoms/neighbours.h"

namespace vd
{

template <class C>
class CrystalAtomsIterator
{
public:
    static C *crystalBy(Atom *atom);

    template <class RL, class AL>
    static void eachNeighbour(Atom *anchor, const RL &relationsMethod, const AL &actionLambda);

    template <ushort ATOMS_NUM, class RL, class AL>
    static void eachNeighbours(Atom **anchors, const RL &relationsMethod, const AL &actionLambda);

protected:
    CrystalAtomsIterator() = default;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class C>
C *CrystalAtomsIterator<C>::crystalBy(Atom *atom)
{
    assert(atom->lattice());
    return static_cast<C *>(atom->lattice()->crystal());
}

template <class C>
template <class RL, class AL>
void CrystalAtomsIterator<C>::eachNeighbour(Atom *anchor, const RL &relationsMethod, const AL &actionLambda)
{
    eachNeighbours<1>(&anchor, relationsMethod, [&actionLambda](Atom **neighbours) {
        actionLambda(neighbours[0]);
    });
}

template <class C>
template <ushort ATOMS_NUM, class RL, class AL>
void CrystalAtomsIterator<C>::eachNeighbours(Atom **anchors, const RL &relationsMethod, const AL &actionLambda)
{
    static_assert(ATOMS_NUM > 0, "Invalid number of atoms");

    C *crystal = nullptr;
    typedef decltype((crystal->*relationsMethod)(nullptr)) NeighboursType;

    NeighboursType arrOfNeighbours[ATOMS_NUM];
    for (ushort n = 0; n < ATOMS_NUM; ++n)
    {
        crystal = crystalBy(anchors[n]);
        arrOfNeighbours[n] = (crystal->*relationsMethod)(anchors[n]);
    }

    Atom *neighbours[ATOMS_NUM];
    for (ushort i = 0; i < NeighboursType::QUANTITY; ++i)
    {
        bool allVisited = true;
        for (ushort n = 0; n < ATOMS_NUM; ++n)
        {
            Atom *neighbour = arrOfNeighbours[n][i];
            if (!neighbour)
            {
                goto next_main_iteration;
            }

            neighbours[n] = neighbour;
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
