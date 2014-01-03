#ifndef FORM_TWO_BOND_H
#define FORM_TWO_BOND_H

#include "../../species/specific/methyl_on_bridge_cbs_cmsu.h"
#include "../typical.h"

class FormTwoBond : public Typical<FORM_TWO_BOND, 1>
{
public:
    static void find(MethylOnBridgeCBsCMsu *target);

    FormTwoBond(SpecificSpec *target) : Typical(target) {}

    double rate() const { return 9e4; }
    void doIt();

    const std::string name() const override { return "form two bond"; }
};

#endif // FORM_TWO_BOND_H
