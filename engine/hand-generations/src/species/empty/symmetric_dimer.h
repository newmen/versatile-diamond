#ifndef SYMMETRIC_DIMER_H
#define SYMMETRIC_DIMER_H

#include "../sidepiece/original_dimer.h"
#include "../empty.h"

class SymmetricDimer : public ParentsSwapWrapper<Empty<DIMER>, OriginalDimer, 0, 1>
{
public:
    SymmetricDimer(OriginalDimer *parent) : ParentsSwapWrapper(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT
};

#endif // SYMMETRIC_DIMER_H
