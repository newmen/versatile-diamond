#ifndef ORIGINAL_DIMER_CRI_CLI_H
#define ORIGINAL_DIMER_CRI_CLI_H

#include "../sidepiece/dimer.h"
#include "../specific.h"

class OriginalDimerCRiCLi : public Specific<Base<DependentSpec<ParentSpec>, DIMER_CRi_CLi, 2>>
{
public:
#if defined(PRINT) || defined(SERIALIZE)
    const char *name() const override;
#endif // PRINT || SERIALIZE

protected:
    OriginalDimerCRiCLi(ParentSpec *parent) : Specific(parent) {}
};

#endif // ORIGINAL_DIMER_CRI_CLI_H
