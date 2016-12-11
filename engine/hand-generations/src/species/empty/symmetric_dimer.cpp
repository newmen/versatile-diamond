#include "symmetric_dimer.h"

#if defined(PRINT) || defined(SERIALIZE)
const char *SymmetricDimer::name() const
{
    static const char value[] = "symmetric dimer";
    return value;
}
#endif // PRINT || SERIALIZE
