#include "bridge_with_dimer.h"
#include "../base/bridge.h"
#include "../sidepiece/dimer.h"
#include "../specific/bridge_with_dimer_cdli.h"

const ushort BridgeWithDimer::Base::__indexes[2] = { 5, 0 };
const ushort BridgeWithDimer::Base::__roles[2] = { 32, 6 };

#ifdef PRINT
const char *BridgeWithDimer::name() const
{
    static const char value[] = "bridge with dimer";
    return value;
}
#endif // PRINT

void BridgeWithDimer::find(Atom *anchor)
{
    if (anchor->is(32))
    {
        if (!anchor->checkAndFind(BRIDGE_WITH_DIMER, 32))
        {
            anchor->eachSpecByRole<Bridge>(6, [&](Bridge *target1) {
                target1->eachSymmetry([&](ParentSpec *specie1) {
                    if (specie1->atom(2) == anchor)
                    {
                        anchor->eachSpecByRole<Dimer>(22, [&](Dimer *target2) {
                            target2->eachSymmetry([&](ParentSpec *specie2) {
                                if (specie2->atom(3) == anchor)
                                {
                                    Atom *atom1 = specie1->atom(1);
                                    ParentSpec *parents[3] = { atom1->specByRole<Bridge>(3), specie1, specie2 };
                                    create<BridgeWithDimer>(parents);
                                }
                            });
                        });
                    }
                });
            });
        }
    }
}

void BridgeWithDimer::findAllChildren()
{
    BridgeWithDimerCDLi::find(this);
}
