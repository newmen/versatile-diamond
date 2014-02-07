#ifndef SHIFTED_DIMER_H
#define SHIFTED_DIMER_H

#include "../sidepiece/dimer.h"
#include "../empty.h"

class ShiftedDimer : public Empty<AtomShiftWrapper, SHIFTED_DIMER>
{
public:
    ShiftedDimer(Dimer *parent) : Empty(3, parent) {}

#ifdef PRINT
    const char *name() const override;
#endif // PRINT
};

#endif // SHIFTED_DIMER_H
