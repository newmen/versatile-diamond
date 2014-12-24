#ifndef DIMER_FORMATION_AT_END_H
#define DIMER_FORMATION_AT_END_H

#include "../concretizable_role.h"
#include "../lateral.h"

class DimerFormationAtEnd : public ConcretizableRole<Lateral, DIMER_FORMATION_AT_END, 1>
{
    static const char __name[];

public:
    static double RATE();

    template <class... Args> DimerFormationAtEnd(Args... args) : ConcretizableRole(args...) {}

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }

    void createUnconcreted(LateralSpec *removableSpec) override;
};

#endif // DIMER_FORMATION_AT_END_H
