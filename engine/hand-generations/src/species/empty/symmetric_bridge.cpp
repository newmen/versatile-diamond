#include "symmetric_bridge.h"

#if defined(PRINT) || defined(SPEC_PRINT) || defined(SERIALIZE)
const char *SymmetricBridge::name() const
{
    static const char value[] = "symmetric bridge";
    return value;
}
#endif // PRINT || SPEC_PRINT || SERIALIZE
