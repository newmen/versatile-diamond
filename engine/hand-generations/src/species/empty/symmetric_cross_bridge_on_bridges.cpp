#include "symmetric_cross_bridge_on_bridges.h"

#if defined(PRINT) || defined(SPEC_PRINT) || defined(JSONLOG)
const char *SymmetricCrossBridgeOnBridges::name() const
{
    static const char value[] = "symmetric_cross_bridge_on_bridges";
    return value;
}
#endif // PRINT || SPEC_PRINT || JSONLOG
