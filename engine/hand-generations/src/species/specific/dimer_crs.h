#ifndef DIMER_CRS_H
#define DIMER_CRS_H

#include "../sidepiece/dimer.h"
#include "../specific.h"

class DimerCRs : public Specific<Base<DependentSpec<BaseSpec>, DIMER_CRs, 1>>
{
public:
    static void find(Dimer *parent);

    DimerCRs(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllTypicalReactions() final;
};

#endif // DIMER_CRS_H
