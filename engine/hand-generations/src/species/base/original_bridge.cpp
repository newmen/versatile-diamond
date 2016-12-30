#include "original_bridge.h"
#include "../empty/symmetric_bridge.h"

template <> const ushort OriginalBridge::Base::__indexes[3] = { 0, 1, 2 };
template <> const ushort OriginalBridge::Base::__roles[3] = { 3, 6, 6 };

#if defined(PRINT) || defined(SPEC_PRINT) || defined(SERIALIZE)
const char *OriginalBridge::name() const
{
    static const char value[] = "bridge";
    return value;
}
#endif // PRINT || SPEC_PRINT || SERIALIZE
