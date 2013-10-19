#include "bridge_cts.h"
#include "../handbook.h"

void BridgeCts::find(BaseSpec *parent)
{
    Atom *atom = parent->atom(0);
    if (!atom->is(1)) return;
    if (!atom->prevIs(1))
    {
        BaseSpec *parents[1] = { parent };
        Atom *atoms[1] = { atom };
        ushort types[1] = { 1 };

        auto bridgeCts = std::shared_ptr<BaseSpec>(new BridgeCts(BRIDGE_CTs, parents, atoms));
        bridgeCts->setupAtomTypes(bridgeCts, types);

//        Handbook::storeBridgeCts(bridgeCts);
    }

//    findChildren(parent);
}

//void BridgeCts::findChildren(Atom *anchor)
//{
//    DimerFormation::find()
//}
