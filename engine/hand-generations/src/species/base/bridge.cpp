#include "bridge.h"
#include "../specific/bridge_ctsi.h"
#include "../specific/high_bridge.h"
#include "bridge_cri.h"
#include "methyl_on_bridge.h"

void Bridge::find(Atom *anchor)
{
    if (anchor->is(3))
    {
        if (!anchor->checkAndFind(BRIDGE, 3))
        {
            if (anchor->lattice()->coords().z == 0) return;

            allNeighbours(anchor, &Diamond::cross_110, [&](Atom **neighbours) {
                if (neighbours[0]->is(6) && anchor->hasBondWith(neighbours[0]) &&
                    neighbours[1]->is(6) && anchor->hasBondWith(neighbours[1]))
                {
                    Atom *atoms[3] = { anchor, neighbours[0], neighbours[1] };
                    create<Bridge>(atoms);
                }
            });
        }
    }
}

void Bridge::findAllChildren()
{
    MethylOnBridge::find(this);
    HighBridge::find(this);
    BridgeCTsi::find(this);
    BridgeCRi::find(this);
}
