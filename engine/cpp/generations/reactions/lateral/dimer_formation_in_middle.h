#ifndef DIMER_FORMATION_IN_MIDDLE_H
#define DIMER_FORMATION_IN_MIDDLE_H

#include "../lateral.h"
#include "dimer_formation_at_end.h"

class DimerFormationInMiddle : public Lateral<DIMER_FORMATION_IN_MIDDLE, 2>
{
public:
//    using Lateral::Lateral;
    DimerFormationInMiddle(SpecReaction *parent, LateralSpec **laterals) : Lateral(parent, laterals) {}

    double rate() const { return 3.1e5; }
    std::string name() const { return "dimer formation in middle of dimers row"; }
};

#endif // DIMER_FORMATION_IN_MIDDLE_H
