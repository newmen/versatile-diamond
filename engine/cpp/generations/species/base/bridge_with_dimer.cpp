#include "bridge_with_dimer.h"
#include "../dolls/swapped_bridge.h"
#include "../dolls/shifted_dimer.h"
#include "../specific/bridge_with_dimer_cdli.h"

void BridgeWithDimer::find(Atom *anchor)
{
    if (anchor->is(32) && anchor->lattice()->coords().z > 0)
    {
        Bridge *topBridge = anchor->specByRole<Bridge>(6);
        ParentSpec *targetBridge;
        if (topBridge->atom(2) == anchor)
        {
            targetBridge = topBridge;
        }
        else
        {
            targetBridge = create<SwappedBridge>(topBridge);
        }

        Dimer *dimer = anchor->specByRole<Dimer>(22);
        ParentSpec *targetDimer;
        if (dimer->atom(3) == anchor)
        {
            targetDimer = dimer;
        }
        else
        {
            targetDimer = create<ShiftedDimer>(dimer);
        }

        ParentSpec *targets[3] = {
            targetBridge->atom(1)->specByRole<Bridge>(3),
            targetBridge,
            targetDimer
        };

        create<BridgeWithDimer>(targets);
    }
}

void BridgeWithDimer::findAllChildren()
{
    BridgeWithDimerCDLi::find(this);
}
