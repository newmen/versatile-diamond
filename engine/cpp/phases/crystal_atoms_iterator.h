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

    // TODO: never used!
    template <ushort RELS_NUM, class RL, class AL>
    static void eachRelations(Atom *anchor, const RL *relationMethods, const AL &actionLambda);
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class C>
C *CrystalAtomsIterator<C>::crystalBy(Atom *atom)
{
    assert(atom->lattice());
    return cast_to<C *>(atom->lattice()->crystal());
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

template <class C>
template <ushort RELS_NUM, class RL, class AL>
void CrystalAtomsIterator<C>::eachRelations(Atom *anchor, const RL *relationMethods, const AL &actionLambda)
{
    static_assert(RELS_NUM > 0, "Invalid number of relations");

    C *crystal = crystalBy(anchor);
    typedef decltype((crystal->*relationMethods[0])(nullptr)) NeighboursType;

    NeighboursType arrOfNeighbours[RELS_NUM];
    for (ushort n = 0; n < RELS_NUM; ++n)
    {
        arrOfNeighbours[n] = (crystal->*relationMethods[n])(anchor);
    }

    Atom *neighbours[RELS_NUM];
    for (ushort i = 0; i < NeighboursType::QUANTITY; ++i)
    {
        // TODO: visiting of atoms is not verifieng for multisearch!
        for (ushort n = 0; n < RELS_NUM; ++n)
        {
            Atom *neighbour = arrOfNeighbours[n][i];
            if (!neighbour)
            {
                goto next_main_iteration;
            }

            neighbours[n] = neighbour;
        }

        actionLambda(neighbours);

        next_main_iteration :;
    }
}

}

#endif // CRYSTAL_ATOMS_ITERATOR_H
