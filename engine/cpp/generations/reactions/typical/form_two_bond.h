#ifndef FORM_TWO_BOND_H
#define FORM_TWO_BOND_H

#include "../../species/specific/methyl_on_bridge_cbs_cmsu.h"
#include "../typical.h"

class FormTwoBond : public Typical<FORM_TWO_BOND, 1>
{
public:
    static constexpr double RATE = 1e7 * exp(-0 / (1.98 * Env::T)); // TODO: imagine

    static void find(MethylOnBridgeCBsCMsu *target);

    FormTwoBond(SpecificSpec *target) : Typical(target) {}

    double rate() const override { return RATE; }
    void doIt() override;

    const char *name() const override;
};

#endif // FORM_TWO_BOND_H
