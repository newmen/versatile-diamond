#include "original_dimer_cri_cli.h"

template <> const ushort OriginalDimerCRiCLi::Base::__indexes[2] = { 0, 3 };
template <> const ushort OriginalDimerCRiCLi::Base::__roles[2] = { 20, 20 };

#if defined(PRINT) || defined(SPEC_PRINT) || defined(JSONLOG)
const char *OriginalDimerCRiCLi::name() const
{
    static const char value[] = "dimer(cr: i, cl: i)";
    return value;
}
#endif // PRINT || SPEC_PRINT || JSONLOG
