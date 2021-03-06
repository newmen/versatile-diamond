#include "bridge_crh.h"
#include "../../reactions/typical/abs_hydrogen_from_gap.h"

template <> const ushort BridgeCRh::Base::__indexes[1] = { 1 };
template <> const ushort BridgeCRh::Base::__roles[1] = { 34 };

#if defined(PRINT) || defined(SPEC_PRINT) || defined(JSONLOG)
const char *BridgeCRh::name() const
{
    static const char value[] = "bridge(cr: H)";
    return value;
}
#endif // PRINT || SPEC_PRINT || JSONLOG

void BridgeCRh::find(BridgeCRi *parent)
{
    Atom *anchor = parent->atom(1);
    if (anchor->is(34))
    {
        if (!anchor->checkAndFind(BRIDGE_CRh, 34))
        {
            create<BridgeCRh>(parent);
        }
    }
}

void BridgeCRh::findAllTypicalReactions()
{
    AbsHydrogenFromGap::find(this);
}
