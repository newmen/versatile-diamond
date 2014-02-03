#ifndef DIMER_FORMATION_IN_MIDDLE_H
#define DIMER_FORMATION_IN_MIDDLE_H

#include "../lateral.h"

class DimerFormationInMiddle : public Lateral<DIMER_FORMATION_IN_MIDDLE, 2>
{
public:
    static constexpr double RATE = 8.9e11 * exp(-0 / (1.98 * Env::T));

    template <class... Args>
    DimerFormationInMiddle(Args... args) : Lateral(args...) {}

    double rate() const override { return RATE; }
    std::string name() const override { return "dimer formation in middle of dimers row"; }

    void createUnconcreted(LateralSpec *removableSpec) override;
};

#endif // DIMER_FORMATION_IN_MIDDLE_H
