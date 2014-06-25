#include "bridge_cri.h"
#include "../specific/bridge_crh.h"
#include "../specific/bridge_crs.h"

const ushort BridgeCRi::__indexes[1] = { 1 };
const ushort BridgeCRi::__roles[1] = { 4 };

#ifdef PRINT
const char *BridgeCRi::name() const
{
    static const char value[] = "bridge(cr: i)";
    return value;
}
#endif // PRINT

void BridgeCRi::find(Bridge *parent)
{
    parent->eachSymmetry([](ParentSpec *specie) {
        Atom *anchor = specie->atom(1);
        if (anchor->is(4))
        {
            if (!anchor->checkAndFind(BRIDGE_CRi, 4))
            {
                create<BridgeCRi>(specie);
            }
        }
    });
}

void BridgeCRi::findAllChildren()
{
    BridgeCRh::find(this);
    BridgeCRs::find(this);
}
