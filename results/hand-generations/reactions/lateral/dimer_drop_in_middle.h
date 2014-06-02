#ifndef DIMER_DROP_IN_MIDDLE_H
#define DIMER_DROP_IN_MIDDLE_H

#include "../lateral.h"

class DimerDropInMiddle : public Lateral<DIMER_DROP_IN_MIDDLE, 2>
{
    static const char __name[];

public:
    static double RATE();

    template <class... Args> DimerDropInMiddle(Args... args) : Lateral(args...) {}

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }

    void createUnconcreted(LateralSpec *removableSpec) override;
};

#endif // DIMER_DROP_IN_MIDDLE_H
