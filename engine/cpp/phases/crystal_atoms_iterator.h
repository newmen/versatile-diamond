#ifndef CRYSTAL_ATOMS_ITERATOR_H
#define CRYSTAL_ATOMS_ITERATOR_H

#include "../atoms/atom.h"
#include "../atoms/neighbours.h"

namespace vd
{

#define DECL_NBRS_TYPE(C, relationsMethod) \
    typename std::result_of<decltype(relationsMethod)(C *, const Atom *)>::type

template <class C>
class CrystalAtomsIterator
{
protected:
    CrystalAtomsIterator() = default;

    static C *crystalBy(Atom *atom);

    template <class RL, class AL>
    static void eachNeighbour(Atom *anchor, const RL &relationsMethod, const AL &actionLambda);

    template <ushort ATOMS_NUM, class RL, class AL>
    static void eachNeighbours(Atom **anchors, const RL &relationsMethod, const AL &actionLambda);

    template <class RL, class AL>
    static void allNeighbours(Atom *anchor, const RL &relationsMethod, const AL &actionLambda);

private:
    template <ushort ATOMS_NUM, class RL, class BL>
    static void resolveAllNeighbours(Atom **anchors, const RL &relationsMethod, const BL &bodyLambda);
};

//////////////////////////////////////////////////////////////////////////////////////

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
    typedef DECL_NBRS_TYPE(C, relationsMethod) NeighboursType;
    resolveAllNeighbours<ATOMS_NUM>(anchors, relationsMethod, [&actionLambda](NeighboursType *arrOfNeighbours) {
        Atom *neighbours[ATOMS_NUM];
        for (ushort i = 0; i < NeighboursType::QUANTITY; ++i)
        {
            bool allVisited = true;
            for (ushort n = 0; n < ATOMS_NUM; ++n)
            {
                Atom *neighbour = arrOfNeighbours[n][i];
                if (neighbour)
                {
                    neighbours[n] = neighbour;
                    allVisited &= neighbour->isVisited();
                }
                else
                {
                    goto next_main_iteration;
                }
            }

            // If many neighbours are unvisited then iterates just in one side
            // because the iteration to the back side will be done by one of neighbour
            if (i == 0 || allVisited)
            {
                actionLambda(neighbours);
            }

            next_main_iteration :;
        }
    });
}

template <class C>
template <class RL, class AL>
void CrystalAtomsIterator<C>::allNeighbours(Atom *anchor, const RL &relationsMethod, const AL &actionLambda)
{
    typedef DECL_NBRS_TYPE(C, relationsMethod) NeighboursType;
    resolveAllNeighbours<1>(&anchor, relationsMethod, [&actionLambda](NeighboursType *arrOfNeighbours) {
        Atom *neighbours[NeighboursType::QUANTITY];
        for (ushort i = 0; i < NeighboursType::QUANTITY; ++i)
        {
            Atom *neighbour = arrOfNeighbours[0][i];
            if (neighbour)
            {
                neighbours[i] = neighbour;
            }
            else
            {
                return; // go out from iterator!
            }
        }

        actionLambda(neighbours);
    });
}

template <class C>
template <ushort ATOMS_NUM, class RL, class BL>
void CrystalAtomsIterator<C>::resolveAllNeighbours(Atom **anchors, const RL &relationsMethod, const BL &bodyLambda)
{
    static_assert(ATOMS_NUM > 0, "Invalid number of atoms");

    typedef DECL_NBRS_TYPE(C, relationsMethod) NeighboursType;
    NeighboursType arrOfNeighbours[ATOMS_NUM];
    for (ushort n = 0; n < ATOMS_NUM; ++n)
    {
        C *crystal = crystalBy(anchors[n]);
        arrOfNeighbours[n] = (crystal->*relationsMethod)(anchors[n]);
    }

    bodyLambda(arrOfNeighbours);
}

}

#endif // CRYSTAL_ATOMS_ITERATOR_H
