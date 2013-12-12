#ifndef DIMER_FORMATION_AT_END_H
#define DIMER_FORMATION_AT_END_H

#include "../concretizable.h"
#include "../lateral_typical.h"

class DimerFormationAtEnd : public Concretizable<LateralTypical<DIMER_FORMATION_AT_END, 1>>
{
public:
    template <class... Args>
    DimerFormationAtEnd(Args... args) : Concretizable(args...) {}

    double rate() const { return 2.6e5; }
    std::string name() const { return "dimer formation at end of dimers row"; }
};

#endif // DIMER_FORMATION_AT_END_H
