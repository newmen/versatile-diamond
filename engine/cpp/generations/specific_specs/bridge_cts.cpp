#include "bridge_cts.h"
#include "../handbook.h"

void BridgeCts::find(BaseSpec *parent)
{
    if (!parent->atom(0)->is(1)) return;
    if (!parent->atom(0)->prevIs(1))
    {
        ushort types[1] = { 1 };
        Atom *atoms[1] = { parent->atom(0) };

        auto bridgeCts = new BridgeCts(BRIDGE_CTs, atoms);
        bridgeCts->setupAtomTypes(types);
        Handbook::storeBridgeCts(bridgeCts);
    }

//    findChildren(parent);
}

//void BridgeCts::findChildren(Atom *anchor)
//{
//    DimerFormation::find()
//}
