#include "symmetric_dimer.h"

#if defined(PRINT) || defined(SPEC_PRINT) || defined(JSONLOG)
const char *SymmetricDimer::name() const
{
    static const char value[] = "symmetric dimer";
    return value;
}
#endif // PRINT || SPEC_PRINT || JSONLOG
