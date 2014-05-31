#ifndef DIMER_DROP_AT_END_H
#define DIMER_DROP_AT_END_H

#include "../concretizable_role.h"
#include "../lateral.h"

class DimerDropAtEnd : public ConcretizableRole<Lateral, DIMER_DROP_AT_END, 1>
{
    static const char __name[];

public:
    static const double RATE;

    template <class... Args> DimerDropAtEnd(Args... args) : ConcretizableRole(args...) {}

    double rate() const override { return RATE; }
    const char *name() const override { return __name; }

    void createUnconcreted(LateralSpec *removableSpec) override;
};

#endif // DIMER_DROP_AT_END_H