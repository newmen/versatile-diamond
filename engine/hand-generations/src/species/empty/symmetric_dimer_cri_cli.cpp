#include "symmetric_dimer_cri_cli.h"

#if defined(PRINT) || defined(SERIALIZE)
const char *SymmetricDimerCRiCLi::name() const
{
    static const char value[] = "symmetric_dimer(cr: i, cl: i)";
    return value;
}
#endif // PRINT || SERIALIZE
