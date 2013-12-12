#ifndef DIMER_FORMATION_IN_MIDDLE_H
#define DIMER_FORMATION_IN_MIDDLE_H

#include "../lateral_typical.h"

class DimerFormationInMiddle : public LateralTypical<DIMER_FORMATION_IN_MIDDLE, 2>
{
public:
    template <class... Args>
    DimerFormationInMiddle(Args... args) : LateralTypical(args...) {}

    double rate() const { return 3.1e5; }
    std::string name() const { return "dimer formation in middle of dimers row"; }
};

#endif // DIMER_FORMATION_IN_MIDDLE_H
