#include "bridge_crh.h"
#include "../../reactions/typical/abs_hydrogen_from_gap.h"

const ushort BridgeCRh::__indexes[1] = { 1 };
const ushort BridgeCRh::__roles[1] = { 34 };

void BridgeCRh::find(BridgeCRi *parent)
{
    Atom *anchor = parent->atom(1);
    if (anchor->is(34))
    {
        if (!checkAndFind<BridgeCRh>(anchor, 34))
        {
            create<BridgeCRh>(parent);
        }
    }
}

void BridgeCRh::findAllReactions()
{
    AbsHydrogenFromGap::find(this);
}
