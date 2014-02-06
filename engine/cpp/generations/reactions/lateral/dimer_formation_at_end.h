#ifndef DIMER_FORMATION_AT_END_H
#define DIMER_FORMATION_AT_END_H

#include "../concretizable_role.h"
#include "../lateral.h"

class DimerFormationAtEnd : public ConcretizableRole<Lateral, DIMER_FORMATION_AT_END, 1>
{
public:
    static constexpr double RATE = 8.9e11 * exp(-0.4e3 / (1.98 * Env::T));

    template <class... Args> DimerFormationAtEnd(Args... args) : ConcretizableRole(args...) {}

    double rate() const override { return RATE; }
    std::string name() const override { return "dimer formation at end of dimers row"; }

    void createUnconcreted(LateralSpec *removableSpec) override;
};

#endif // DIMER_FORMATION_AT_END_H
