#ifndef METHYL_TO_HIGH_BRIDGE_H
#define METHYL_TO_HIGH_BRIDGE_H

#include "../../species/specific/methyl_on_dimer_cmsiu.h"
#include "../typical.h"

class MethylToHighBridge : public Typical<METHYL_TO_HIGH_BRIDGE>
{
    static const char __name[];

public:
    static double RATE();

    static void find(MethylOnDimerCMsiu *target);

    MethylToHighBridge(SpecificSpec *target) : Typical(target) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }
};

#endif // METHYL_TO_HIGH_BRIDGE_H
