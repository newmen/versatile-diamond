#ifndef DES_METHYL_FROM_BRIDGE_H
#define DES_METHYL_FROM_BRIDGE_H

#include "../../species/specific/methyl_on_bridge_cbi_cmu.h"
#include "../typical.h"

class DesMethylFromBridge : public Typical<DES_METHYL_FROM_BRIDGE>
{
public:
    static constexpr double RATE = 1.7e7 * exp(-0 / (1.98 * Env::T));

    static void find(MethylOnBridgeCBiCMu *target);

    DesMethylFromBridge(SpecificSpec *target) : Typical(target) {}

    double rate() const override { return RATE; }
    void doIt() override;

    const char *name() const override;
};

#endif // DES_METHYL_FROM_BRIDGE_H
