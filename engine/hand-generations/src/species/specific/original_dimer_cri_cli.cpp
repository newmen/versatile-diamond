#include "original_dimer_cri_cli.h"

const ushort OriginalDimerCRiCLi::Base::__indexes[2] = { 0, 3 };
const ushort OriginalDimerCRiCLi::Base::__roles[2] = { 20, 20 };

#ifdef PRINT
const char *OriginalDimerCRiCLi::name() const
{
    static const char value[] = "dimer(cr: i, cl: i)";
    return value;
}
#endif // PRINT
