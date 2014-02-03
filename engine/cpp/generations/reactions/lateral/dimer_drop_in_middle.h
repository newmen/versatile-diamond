#ifndef DIMER_DROP_IN_MIDDLE_H
#define DIMER_DROP_IN_MIDDLE_H

#include "../lateral.h"

class DimerDropInMiddle : public Lateral<DIMER_DROP_IN_MIDDLE, 2>
{
public:
    static constexpr double RATE = 2.2e6 * exp(-1.2e3 / (1.98 * Env::T));

    template <class... Args>
    DimerDropInMiddle(Args... args) : Lateral(args...) {}

    double rate() const override { return RATE; }
    std::string name() const override { return "dimer drop in middle of dimers row"; }

    void createUnconcreted(LateralSpec *removableSpec) override;
};

#endif // DIMER_DROP_IN_MIDDLE_H
