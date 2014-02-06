#ifndef DIMER_DROP_AT_END_H
#define DIMER_DROP_AT_END_H

#include "../concretizable_role.h"
#include "../lateral.h"

class DimerDropAtEnd : public ConcretizableRole<Lateral, DIMER_DROP_AT_END, 1>
{
public:
    static constexpr double RATE = 2.2e6 * exp(-1e3 / (1.98 * Env::T));

    template <class... Args> DimerDropAtEnd(Args... args) : ConcretizableRole(args...) {}

    double rate() const override { return RATE; }
    const char *name() const override;

    void createUnconcreted(LateralSpec *removableSpec) override;
};

#endif // DIMER_DROP_AT_END_H
