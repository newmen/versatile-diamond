#include "bridge.h"
#include "../specific/bridge_ctsi.h"
#include "../specific/high_bridge.h"
#include "bridge_cri.h"
#include "methyl_on_bridge.h"
#include "two_bridges.h"
#include "bridge_with_dimer.h"

const ushort Bridge::__indexes[3] = { 0, 1, 2 };
const ushort Bridge::__roles[3] = { 3, 6, 6 };

void Bridge::find(Atom *anchor)
{
    if (anchor->is(3))
    {
        if (!anchor->checkAndFind(BRIDGE, 3))
        {
            auto diamond = crystalBy(anchor);
            if (anchor->lattice()->coords().z == 0) return;

            auto nbrs = diamond->cross_110(anchor);
            if (nbrs.all() &&
                    nbrs[0]->is(6) && anchor->hasBondWith(nbrs[0]) &&
                    nbrs[1]->is(6) && anchor->hasBondWith(nbrs[1]))
            {
                Atom *atoms[3] = { anchor, nbrs[0], nbrs[1] };
                create<Bridge>(atoms);
            }
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
