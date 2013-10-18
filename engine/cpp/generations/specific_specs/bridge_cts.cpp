#include "bridge_cts.h"

void BridgeCts::find(Atom *anchor)
{
    if (!anchor->is(1)) return;
    if (!anchor->prevIs(1))
    {
        assert(anchor->lattice());

        auto bridgeCts = new BridgeCts({ 1 }, { anchor });

    }

//    findChildren(anchor);
}
