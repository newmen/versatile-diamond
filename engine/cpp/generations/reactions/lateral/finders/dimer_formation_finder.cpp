#include "dimer_formation_finder.h"
#include "../../../species/lateral/dimer.h"
#include "../../typical/dimer_formation.h"
#include "../dimer_formation_at_end.h"
#include "../dimer_formation_in_middle.h"

LateralReaction *DimerFormationFinder::find(SpecReaction *unlateralizedReaction)
{
#ifdef DEBUG
    auto parent = dynamic_cast<DimerFormation *>(unlateralizedReaction);
    assert(parent);
#else
    auto parent = static_cast<DimerFormation *>(unlateralizedReaction);
#endif // DEBUG

    Atom *atoms[2] = {
        parent->target(0)->anchor(),
        parent->target(1)->anchor()
    };

    LateralSpec *neighbourSpecs[2] = { nullptr, nullptr };
    LateralReaction *concreted = nullptr;
    eachNeighbours<2>(atoms, &Diamond::cross_100, [&neighbourSpecs, &concreted, parent](Atom **neighbours) {
        if (neighbours[0]->is(22) && neighbours[1]->is(22))
        {
            LateralSpec *specInNeighbour[2] = {
                neighbours[0]->specByRole<Dimer>(22),
                neighbours[1]->specByRole<Dimer>(22)
            };

            auto sidepiece = specInNeighbour[0];
            if (sidepiece && specInNeighbour[0] == specInNeighbour[1])
            {
                if (neighbourSpecs[0])
                {
                    neighbourSpecs[1] = sidepiece;
                    concreted = new DimerFormationInMiddle(parent, neighbourSpecs);
                }
                else
                {
                    concreted = new DimerFormationAtEnd(parent, sidepiece);
                    neighbourSpecs[0] = sidepiece;
                }
            }
        }
    });
    return concreted;
}

