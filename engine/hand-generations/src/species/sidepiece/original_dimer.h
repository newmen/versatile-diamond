#ifndef ORIGINAL_DIMER_H
#define ORIGINAL_DIMER_H

#include "../base.h"
#include "../sidepiece.h"

class OriginalDimer : public Sidepiece<Base<DependentSpec<ParentSpec, 2>, DIMER, 2>>
{
public:
#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    OriginalDimer(ParentSpec **parents) : Sidepiece(parents) {}
};

#endif // ORIGINAL_DIMER_H
