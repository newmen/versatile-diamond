#include "original_dimer.h"

template <> const ushort OriginalDimer::Base::__indexes[2] = { 0, 3 };
template <> const ushort OriginalDimer::Base::__roles[2] = { 22, 22 };

#ifdef PRINT
const char *OriginalDimer::name() const
{
    static const char value[] = "dimer";
    return value;
}
#endif // PRINT
