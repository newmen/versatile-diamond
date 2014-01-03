#ifndef DIMER_DROP_IN_MIDDLE_H
#define DIMER_DROP_IN_MIDDLE_H

#include "../lateral.h"

class DimerDropInMiddle : public Lateral<DIMER_DROP_IN_MIDDLE, 2>
{
public:
    template <class... Args>
    DimerDropInMiddle(Args... args) : Lateral(args...) {}

    double rate() const { return 4.8e3; }
    const std::string name() const { return "dimer drop in middle of dimers row"; }

    void createUnconcreted(LateralSpec *removableSpec) override;
};

#endif // DIMER_DROP_IN_MIDDLE_H
