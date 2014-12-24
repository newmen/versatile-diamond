#ifndef SYMMETRIC_DIMER_CRI_CLI_H
#define SYMMETRIC_DIMER_CRI_CLI_H

#include "../specific/original_dimer_cri_cli.h"

class SymmetricDimerCRiCLi :
        public ParentsSwapProxy<OriginalDimer, SymmetricDimer, DIMER_CRi_CLi>
{
public:
    SymmetricDimerCRiCLi(OriginalDimerCRiCLi *parent) : ParentsSwapProxy(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT
};

#endif // SYMMETRIC_DIMER_CRI_CLI_H
