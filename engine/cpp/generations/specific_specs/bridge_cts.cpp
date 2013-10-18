#include "bridge_cts.h"
#include "../handbook.h"

void BridgeCts::find(Atom *anchor)
{
    if (!anchor->is(1)) return;
    if (!anchor->prevIs(1))
    {
        assert(anchor->lattice());
        ushort types[1] = { 1 };
        Atom *atoms[1] = { anchor };

        auto bridgeCts = new BridgeCts(BRIDGE_CTs, atoms);
        bridgeCts->setupAtomTypes(types);
        Handbook::storeBridgeCts(bridgeCts);
    }

//    findChildren(anchor);
}
