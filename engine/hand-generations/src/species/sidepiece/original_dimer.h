#ifndef ORIGINAL_DIMER_H
#define ORIGINAL_DIMER_H

#include "../base.h"
#include "../sidepiece.h"

class OriginalDimer : public Sidepiece<Base<DependentSpec<ParentSpec, 2>, DIMER, 2>>
{
public:
#if defined(PRINT) || defined(SERIALIZE)
    const char *name() const override;
#endif // PRINT || SERIALIZE

protected:
    OriginalDimer(ParentSpec **parents) : Sidepiece(parents) {}
};

#endif // ORIGINAL_DIMER_H
