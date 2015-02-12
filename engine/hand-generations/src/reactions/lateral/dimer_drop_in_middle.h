#ifndef DIMER_DROP_IN_MIDDLE_H
#define DIMER_DROP_IN_MIDDLE_H

#include "../multi_lateral.h"

class DimerDropInMiddle : public MultiLateral<DIMER_DROP_IN_MIDDLE, 2>
{
    static const char __name[];

public:
    static double RATE();

    template <class... Args> DimerDropInMiddle(Args... args) : MultiLateral(args...) {}

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }
};

#endif // DIMER_DROP_IN_MIDDLE_H
