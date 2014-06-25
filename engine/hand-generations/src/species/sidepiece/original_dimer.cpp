#include "original_dimer.h"

const ushort OriginalDimer::__indexes[2] = { 0, 3 };
const ushort OriginalDimer::__roles[2] = { 22, 22 };

#ifdef PRINT
const char *OriginalDimer::name() const
{
    static const char value[] = "dimer";
    return value;
}
#endif // PRINT
