#ifndef NEAR_GAP_H
#define NEAR_GAP_H

#include "../../../../tools/creator.h"
#include "../../../phases/diamond.h"
#include "../../../phases/diamond_atoms_iterator.h"
#include "../../../species/specific/bridge_crs.h"

class NearGap : public DiamondAtomsIterator, public Creator
{
public:
    template <class R> static void look(SpecificSpec *target);
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class R>
void NearGap::look(SpecificSpec *target)
{
    Atom *atoms[2] = { target->atom(2), target->atom(3) };
    eachNeighbours<2>(atoms, &Diamond::cross_100, [target](Atom **neighbours) {
        if (neighbours[0]->is(5) && neighbours[1]->is(5))
        {
            SpecificSpec *first = neighbours[0]->specByRole<BridgeCRs>(5);
            if (first->atom(2) != neighbours[1])
            {
                SpecificSpec *second = neighbours[1]->specByRole<BridgeCRs>(5);
                assert(second->atom(2) != neighbours[0]);

                SpecificSpec *targets[3] = { target, first, second };
                create<R>(targets);
            }
        }
    });
}

#endif // NEAR_GAP_H
