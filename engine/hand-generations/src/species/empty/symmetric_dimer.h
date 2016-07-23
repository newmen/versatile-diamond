#ifndef SYMMETRIC_DIMER_H
#define SYMMETRIC_DIMER_H

#include "../sidepiece/original_dimer.h"
#include "../empty_base.h"

class SymmetricDimer :
    public ParentsSwapWrapper<EmptyBase<DIMER>, OriginalDimer, 0, 1>
{
public:
    SymmetricDimer(OriginalDimer *parent) : ParentsSwapWrapper(parent) {}

#ifdef PRINT
    const char *name() const override;
#endif // PRINT
};

#endif // SYMMETRIC_DIMER_H
