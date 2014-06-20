#ifndef FORM_TWO_BOND_H
#define FORM_TWO_BOND_H

#include "../../species/specific/methyl_on_bridge_cbs_cmsiu.h"
#include "../typical.h"

class FormTwoBond : public Typical<FORM_TWO_BOND, 1>
{
    static const char __name[];

public:
    static double RATE();

    static void find(MethylOnBridgeCBsCMsiu *target);

    FormTwoBond(SpecificSpec *target) : Typical(target) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }
};

#endif // FORM_TWO_BOND_H
