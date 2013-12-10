#ifndef DIMER_FORMATION_AT_END_H
#define DIMER_FORMATION_AT_END_H

#include "../lateral.h"

class DimerFormationAtEnd : public Lateral<DIMER_FORMATION_AT_END, 1>
{
public:
//    using Lateral::Lateral;
    DimerFormationAtEnd(SpecReaction *parent, LateralSpec *lateral) : Lateral(parent, lateral) {}

    double rate() const { return 2.6e5; }
    std::string name() const { return "dimer formation at end of dimers row"; }
};

#endif // DIMER_FORMATION_AT_END_H
