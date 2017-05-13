#ifndef DIMER_CRS_H
#define DIMER_CRS_H

#include "../sidepiece/dimer.h"
#include "../specific.h"

class DimerCRs : public Specific<Base<DependentSpec<BaseSpec>, DIMER_CRs, 1>>
{
public:
    static void find(Dimer *parent);

    DimerCRs(ParentSpec *parent) : Specific(parent) {}

#if defined(PRINT) || defined(SPEC_PRINT) || defined(JSONLOG)
    const char *name() const override;
#endif // PRINT || SPEC_PRINT || JSONLOG

protected:
    void findAllTypicalReactions() final;
};

#endif // DIMER_CRS_H
