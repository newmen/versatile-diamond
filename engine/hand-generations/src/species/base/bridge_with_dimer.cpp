#include "bridge_with_dimer.h"
#include "../base/bridge.h"
#include "../sidepiece/dimer.h"
#include "../specific/bridge_with_dimer_cdli.h"

template <> const ushort BridgeWithDimer::Base::__indexes[2] = { 5, 0 };
template <> const ushort BridgeWithDimer::Base::__roles[2] = { 32, 6 };

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
            ParentSpec *targetBridge = topBridge->selectSymmetry([anchor](ParentSpec *specie) {
                return specie->atom(2) == anchor;
            });

            Dimer *dimer = anchor->specByRole<Dimer>(22);
            ParentSpec *targetDimer = dimer->selectSymmetry([anchor](ParentSpec *specie) {
                return specie->atom(3) == anchor;
            });

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
