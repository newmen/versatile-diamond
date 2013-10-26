#include "bridge_cts.h"
#include "../handbook.h"
#include "../reactions/typical/dimer_formation.h"

#ifdef PRINT
#ifdef PARALLEL
#include <omp.h>
#endif // PARALLEL
#include <iostream>
#endif // PRINT

void BridgeCTs::find(BaseSpec *parent)
{
    Atom *anchor = parent->atom(0);

    if (anchor->is(28))
    {
        if (!anchor->prevIs(28))
        {
            BaseSpec *parents[1] = { parent };
            auto bridgeCts = std::shared_ptr<BaseSpec>(new BridgeCTs(BRIDGE_CTs, parents));
            anchor->describe(28, bridgeCts);

#ifdef PRINT
#ifdef PARALLEL
#pragma omp critical
            {
#endif // PARALLEL
                std::cout << "BridgeCTs at ";
                bridgeCts->info();
                std::cout << " was found" << std::endl;
#ifdef PARALLEL
            }
#endif // PARALLEL
#endif // PRINT

            Handbook::keeper().store<BRIDGE_CTs>(bridgeCts.get());
        }
    }
    else
    {
        if (anchor->hasRole(28, BRIDGE_CTs))
        {
            auto spec = anchor->specByRole(28, BRIDGE_CTs);
            auto bridgeCts = dynamic_cast<ReactionsMixin *>(spec);
            bridgeCts->removeReactions(); // TODO: race condition!!

//            bridgeCts->eachReaction([bridgeCts](SingleReaction *reaction) {
//                ReactionsMixin *other = *reaction->anotherTargets(bridgeCts);
//                auto baseOther = dynamic_cast<BaseSpec *>(other);
//                Atom *anotherAnchor = baseOther->atom(0);
//                if (anotherAnchor->isVisited())
//            });

#ifdef PRINT
#ifdef PARALLEL
#pragma omp critical
            {
#endif // PARALLEL
                std::cout << "BridgeCTs at ";
                spec->info();
                std::cout << " was forgotten" << std::endl;
#ifdef PARALLEL
            }
#endif // PARALLEL
#endif // PRINT
            anchor->forget(28, BRIDGE_CTs);
        }
    }
}

void BridgeCTs::findChildren()
{
    DimerFormation::find(this);
}
