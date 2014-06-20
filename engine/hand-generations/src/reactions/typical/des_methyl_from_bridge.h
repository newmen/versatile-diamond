#ifndef DES_METHYL_FROM_BRIDGE_H
#define DES_METHYL_FROM_BRIDGE_H

#include "../../species/specific/methyl_on_bridge_cbi_cmiu.h"
#include "../typical.h"

class DesMethylFromBridge : public Typical<DES_METHYL_FROM_BRIDGE>
{
    static const char __name[];

public:
    static double RATE();

    static void find(MethylOnBridgeCBiCMiu *target);

    DesMethylFromBridge(SpecificSpec *target) : Typical(target) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }
};

#endif // DES_METHYL_FROM_BRIDGE_H
