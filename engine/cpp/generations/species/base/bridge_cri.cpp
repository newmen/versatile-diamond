#include "bridge_cri.h"
#include "../specific/bridge_crh.h"
#include "../specific/bridge_crs.h"

const ushort BridgeCRi::__indexes[1] = { 1 };
const ushort BridgeCRi::__roles[1] = { 4 };

void BridgeCRi::find(Bridge *parent)
{
    const ushort checkingIndexes[2] = { 1, 2 };

    for (int i = 0; i < 2; ++i)
    {
        Atom *anchor = parent->atom(checkingIndexes[i]);
        if (anchor->is(4))
        {
            if (!checkAndFind<BridgeCRi>(anchor, 4))
            {
                create<BridgeCRi>(checkingIndexes[i], 1, parent);
            }
        }
    }
}

void BridgeCRi::findAllChildren()
{
    BridgeCRh::find(this);
    BridgeCRs::find(this);
}
