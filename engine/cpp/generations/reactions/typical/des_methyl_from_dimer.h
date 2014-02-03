#ifndef DES_METHYL_FROM_DIMER_H
#define DES_METHYL_FROM_DIMER_H

#include "../../species/specific/methyl_on_dimer_cmu.h"
#include "../typical.h"

class DesMethylFromDimer : public Typical<DES_METHYL_FROM_DIMER>
{
public:
    static constexpr double RATE = 5.3e3 * exp(-0 / (1.98 * Env::T));

    // TODO: methyl_on_dimer(cm: u, cm: i) should be used
    static void find(MethylOnDimerCMu *target);

    DesMethylFromDimer(SpecificSpec *target) : Typical(target) {}

    double rate() const override { return RATE; }
    void doIt() override;

    std::string name() const override { return "desorption methyl from dimer"; }
};

#endif // DES_METHYL_FROM_DIMER_H
