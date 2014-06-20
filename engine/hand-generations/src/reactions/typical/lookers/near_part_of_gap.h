#ifndef NEAR_PART_OF_GAP_H
#define NEAR_PART_OF_GAP_H

#include "../../../phases/diamond.h"
#include "../../../phases/diamond_atoms_iterator.h"
#include "../../../species/specific/bridge_crs.h"

class NearPartOfGap : public DiamondAtomsIterator
{
public:
    template <class L> static void look(SpecificSpec *target, const L &lambda);
};

//////////////////////////////////////////////////////////////////////////////////////

template <class L>
void NearPartOfGap::look(SpecificSpec *target, const L &lambda)
{
    Atom *anchor = target->atom(1);
    assert(anchor->is(5));

    eachNeighbour(anchor, &Diamond::front_100, [target, anchor, lambda](Atom *neighbour) {
        if (neighbour->is(5) && target->atom(2) != neighbour)
        {
            auto neighbourBridge = neighbour->specByRole<BridgeCRs>(5);
            if (neighbourBridge)
            {
                assert(neighbourBridge->atom(2) != anchor);

                Atom *anchors[2] = {
                    anchor,
                    neighbourBridge->atom(1)
                };

                lambda(neighbourBridge, anchors);
            }
        }
    });
}

#endif // NEAR_PART_OF_GAP_H
