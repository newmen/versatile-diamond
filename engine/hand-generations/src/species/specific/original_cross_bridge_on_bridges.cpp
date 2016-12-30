#include "original_cross_bridge_on_bridges.h"

template <> const ushort OriginalCrossBridgeOnBridges::Base::__indexes[3] = { 1, 5, 0 };
template <> const ushort OriginalCrossBridgeOnBridges::Base::__roles[3] = { 9, 9, 10 };

#if defined(PRINT) || defined(SPEC_PRINT) || defined(SERIALIZE)
const char *OriginalCrossBridgeOnBridges::name() const
{
    static const char value[] = "cross_bridge_on_bridges";
    return value;
}
#endif // PRINT || SPEC_PRINT || SERIALIZE

