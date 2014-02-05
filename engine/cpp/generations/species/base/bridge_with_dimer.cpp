#include "bridge_with_dimer.h"
#include "../sidepiece/dimer.h"
#include "../specific/bridge_with_dimer_cdli.h"
#include "shifted_dimer.h"

void BridgeWithDimer::find(Bridge *parent)
{
    Atom *anchor = parent->atom(0);
    assert(anchor->lattice());

    if (anchor->lattice()->coords().z > 1)
    {
        const ushort bottomIndexes[2] = { 1, 2 };
        const ushort nearIndexes[2] = { 2, 1 };

        for (int i = 0; i < 2; ++i)
        {
            Atom *bridgeAnchor = parent->atom(bottomIndexes[i]);
            Atom *dimerAnchor = parent->atom(nearIndexes[i]);

            assert(bridgeAnchor->is(6));
            if (dimerAnchor->is(32))
            {
                auto bridge = bridgeAnchor->specByRole<Bridge>(3);
                assert(bridge);

                auto dimer = dimerAnchor->specByRole<Dimer>(22);
                assert(dimer);

                ParentSpec *parents[3] = { parent, bridge, nullptr };

                const ushort checkingIndex[2] = { 0, 3 };
                for (int j = 0; j < 2; ++j)
                {
                    if (dimer->atom(checkingIndex[j]) == dimerAnchor)
                    {
                        if (j == 0)
                        {
                            parents[2] = dimer;
                        }
                        else
                        {
                            parents[2] = create<ShiftedDimer>(dimer);
                        }
                        break;
                    }
                }

                create<BridgeWithDimer>(bottomIndexes[i], 1, parents);
                break;
            }
        }
    }
}

void BridgeWithDimer::findAllChildren()
{
    BridgeWithDimerCDLi::find(this);
}
