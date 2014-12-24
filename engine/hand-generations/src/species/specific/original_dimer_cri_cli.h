#ifndef ORIGINAL_DIMER_CRI_CLI_H
#define ORIGINAL_DIMER_CRI_CLI_H

#include "../sidepiece/dimer.h"
#include "../specific.h"

class OriginalDimerCRiCLi : public Specific<Base<DependentSpec<ParentSpec>, DIMER_CRi_CLi, 2>>
{
public:
#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    OriginalDimerCRiCLi(ParentSpec *parent) : Specific(parent) {}
};

#endif // ORIGINAL_DIMER_CRI_CLI_H
