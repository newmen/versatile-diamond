#include "dimer_formation_finder.h"
#include "../../typical/dimer_formation.h"
#include "../dimer_formation_at_end.h"
#include "../dimer_formation_in_middle.h"

LateralReaction *DimerFormationFinder::find(SpecReaction *unlateralizedReaction)
{
    auto parent = static_cast<DimerFormation *>(unlateralizedReaction);
    Atom *atoms[2] = {
        parent->target(0)->anchor(),
        parent->target(1)->anchor()
    };
    auto diamond = crystalBy<Diamond>(atoms[0]);

    LateralSpec *neighbourSpecs[2] = { nullptr, nullptr };
    LateralReaction *concreted = nullptr;
    eachNeighbours<2>(atoms, diamond, &Diamond::cross_100, [&neighbourSpecs, &concreted, parent](Atom **neighbours) {
        if (neighbours[0]->is(22) && neighbours[1]->is(22))
        {
            LateralSpec *specInNeighbour[2] = {
                neighbours[0]->specByRole<LateralSpec>(22, DIMER),
                neighbours[1]->specByRole<LateralSpec>(22, DIMER)
            };

            if (specInNeighbour[0] && specInNeighbour[0] == specInNeighbour[1])
            {
                if (neighbourSpecs[0])
                {
                    neighbourSpecs[1] = specInNeighbour[0];
                    concreted = new DimerFormationInMiddle(parent, neighbourSpecs);
                }
                else
                {
                    concreted = new DimerFormationAtEnd(parent, specInNeighbour[0]);
                    neighbourSpecs[0] = specInNeighbour[0];
                }
            }
        }
    });
    return concreted;
}

