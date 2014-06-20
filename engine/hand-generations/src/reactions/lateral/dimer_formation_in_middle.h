#ifndef DIMER_FORMATION_IN_MIDDLE_H
#define DIMER_FORMATION_IN_MIDDLE_H

#include "../lateral.h"

class DimerFormationInMiddle : public Lateral<DIMER_FORMATION_IN_MIDDLE, 2>
{
    static const char __name[];

public:
    static double RATE();

    template <class... Args> DimerFormationInMiddle(Args... args) : Lateral(args...) {}

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }

    void createUnconcreted(LateralSpec *removableSpec) override;
};

#endif // DIMER_FORMATION_IN_MIDDLE_H
