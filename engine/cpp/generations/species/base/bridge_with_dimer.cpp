#include "bridge_with_dimer.h"
#include "../empty/swapped_bridge.h"
#include "../empty/shifted_dimer.h"
#include "../specific/bridge_with_dimer_cdli.h"

const ushort BridgeWithDimer::__indexes[1] = { 5 };
const ushort BridgeWithDimer::__roles[1] = { 32 };

#ifdef PRINT
const char *BridgeWithDimer::name() const
{
    static const char value[] = "bridge with dimer";
    return value;
}
#endif // PRINT

void BridgeWithDimer::find(Atom *anchor)
{
    if (anchor->is(32) && anchor->lattice()->coords().z > 0)
    {
        if (!anchor->checkAndFind(BRIDGE_WITH_DIMER, 32))
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
}

void BridgeWithDimer::findAllChildren()
{
    BridgeWithDimerCDLi::find(this);
}
