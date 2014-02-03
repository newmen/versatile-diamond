#ifndef METHYL_TO_HIGH_BRIDGE_H
#define METHYL_TO_HIGH_BRIDGE_H

#include "../../species/specific/methyl_on_dimer_cmsu.h"
#include "../typical.h"

class MethylToHighBridge : public Typical<METHYL_TO_HIGH_BRIDGE>
{
public:
    static constexpr double RATE = 9.8e10 * exp(-15.3e3 / (1.98 * Env::T)); // REAL: A = 9.8e12

    static void find(MethylOnDimerCMsu *target);

    MethylToHighBridge(SpecificSpec *target) : Typical(target) {}

    double rate() const override { return RATE; }
    void doIt() override;

    std::string name() const override { return "methyl to high bridge"; }
};

#endif // METHYL_TO_HIGH_BRIDGE_H
