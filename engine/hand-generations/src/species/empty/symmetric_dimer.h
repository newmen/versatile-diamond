#ifndef SYMMETRIC_DIMER_H
#define SYMMETRIC_DIMER_H

#include "../sidepiece/original_dimer.h"
#include "../empty_base.h"

class SymmetricDimer :
    public ParentsSwapWrapper<EmptyBase<DIMER>, OriginalDimer, 0, 1>
{
public:
    SymmetricDimer(OriginalDimer *parent) : ParentsSwapWrapper(parent) {}

#if defined(PRINT) || defined(SPEC_PRINT) || defined(SERIALIZE)
    const char *name() const override;
#endif // PRINT || SPEC_PRINT || SERIALIZE
};

#endif // SYMMETRIC_DIMER_H
