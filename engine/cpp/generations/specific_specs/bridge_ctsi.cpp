#include "bridge_ctsi.h"
#include "../handbook.h"
#include "../reactions/typical/dimer_formation.h"
#include "../reactions/typical/high_bridge_stand_to_one_bridge.h"

void BridgeCTsi::find(Bridge *parent)
{
    Atom *anchor = parent->atom(0);

    if (anchor->is(28))
    {
        if (!anchor->hasRole(28, BRIDGE_CTsi))
        {
            auto spec = new BridgeCTsi(BRIDGE_CTsi, parent);

#ifdef PRINT
            spec->wasFound();
#endif // PRINT

            anchor->describe(28, spec);

            Handbook::keeper.store<KEE_BRIDGE_CTsi>(spec);
        }
    }
    else
    {
        auto spec = anchor->specificSpecByRole(28, BRIDGE_CTsi);
        if (spec)
        {
            spec->removeReactions();

#ifdef PRINT
            spec->wasForgotten();
#endif // PRINT

            anchor->forget(28, spec);
            Handbook::scavenger.markSpec<BRIDGE_CTsi>(spec);
        }
    }
}

void BridgeCTsi::findChildren()
{
#ifdef PARALLEL
#pragma omp parallel sections
    {
#pragma omp section
        {
#endif // PARALLEL
            DimerFormation::find(this);
#ifdef PARALLEL
        }
#pragma omp section
        {
#endif // PARALLEL
            HighBridgeStandToOneBridge::find(this);
#ifdef PARALLEL
        }
    }
#endif // PARALLEL

}
