#ifndef DIMER_FORMATION_AT_END_H
#define DIMER_FORMATION_AT_END_H

#include "../concretizable_role.h"
#include "../lateral.h"

class DimerFormationAtEnd : public ConcretizableRole<Lateral, DIMER_FORMATION_AT_END, 1>
{
public:
    template <class... Args>
    DimerFormationAtEnd(Args... args) : ConcretizableRole(args...) {}

    double rate() const { return 2.6e5; }
    std::string name() const { return "dimer formation at end of dimers row"; }

    void createUnconcreted(LateralSpec *removableSpec) override;
};

#endif // DIMER_FORMATION_AT_END_H
