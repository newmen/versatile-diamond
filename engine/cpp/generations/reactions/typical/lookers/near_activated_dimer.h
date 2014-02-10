#ifndef NEAR_ACTIVATED_DIMER_H
#define NEAR_ACTIVATED_DIMER_H

#include "../../../../tools/creator.h"
#include "../../../phases/diamond.h"
#include "../../../phases/diamond_atoms_iterator.h"
#include "../../../species/specific/dimer_crs.h"

class NearActivatedDimer : public DiamondAtomsIterator, public Creator
{
public:
    template <class R> static void look(SpecificSpec *target);
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class R>
void NearActivatedDimer::look(SpecificSpec *target)
{
    Atom *atoms[2] = { target->atom(2), target->atom(3) };
    eachNeighbours<2>(atoms, &Diamond::cross_100, [target](Atom **neighbours) {
        if (neighbours[0]->is(22) && neighbours[1]->is(22) && neighbours[0]->hasBondWith(neighbours[1]))
        {
            for (int i = 0; i < 2; ++i)
            {
                if (neighbours[i]->is(21))
                {
                    auto dimerCRs = neighbours[i]->specByRole<DimerCRs>(21);
                    assert(dimerCRs);
                    assert(dimerCRs->atom(3) == neighbours[1 - i]);

                    SpecificSpec *targets[2] = { dimerCRs, target };
                    create<R>(targets);
                    break;
                }
            }
        }
    });
}

#endif // NEAR_ACTIVATED_DIMER_H
