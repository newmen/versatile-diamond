#ifndef DIMER_H
#define DIMER_H

#include "../../phases/diamond_atoms_iterator.h"
#include "../empty/symmetric_dimer.h"
#include "original_dimer.h"

class Dimer : public Symmetric<OriginalDimer, SymmetricDimer>, public DiamondAtomsIterator
{
public:
    static void find(Atom *anchor);
    template <class L> static void row(Atom **anchors, const L &lambda);

    Dimer(ParentSpec **parents) : Symmetric(parents) {}

protected:
    void findAllChildren() final;
    void findAllLateralReactions() final;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class L>
void Dimer::row(Atom **anchors, const L &lambda)
{
    eachNeighbours<2>(anchors, &Diamond::cross_100, [&lambda](Atom **neighbours) {
        if (neighbours[0]->is(22) && neighbours[1]->is(22))
        {
            LateralSpec *specsInNeighbour[2] = {
                neighbours[0]->specByRole<Dimer>(22),
                neighbours[1]->specByRole<Dimer>(22)
            };

            if (specsInNeighbour[0] && specsInNeighbour[0] == specsInNeighbour[1])
            {
                lambda(specsInNeighbour[0]);
            }
        }
    });
}

#endif // DIMER_H
