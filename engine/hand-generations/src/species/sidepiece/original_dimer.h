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

    const ushort *indexes() const final { return __indexes; }
    const ushort *roles() const final { return __roles; }

private:
    static const ushort __indexes[2];
    static const ushort __roles[2];
};

#endif // ORIGINAL_DIMER_H
