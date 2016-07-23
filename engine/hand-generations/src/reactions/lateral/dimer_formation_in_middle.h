#ifndef DIMER_FORMATION_IN_MIDDLE_H
#define DIMER_FORMATION_IN_MIDDLE_H

#include "../multi_lateral.h"

class DimerFormationInMiddle : public MultiLateral<DIMER_FORMATION_IN_MIDDLE, 2>
{
    static const char __name[];

public:
    static double RATE();

    template <class... Args> DimerFormationInMiddle(Args... args) : MultiLateral(args...) {}

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }
};

#endif // DIMER_FORMATION_IN_MIDDLE_H
