#ifndef DES_METHYL_FROM_BRIDGE_H
#define DES_METHYL_FROM_BRIDGE_H

#include "../../species/specific/methyl_on_bridge_cbi_cmu.h"
#include "../mono_typical.h"

class DesMethylFromBridge : public MonoTypical<DES_METHYL_FROM_BRIDGE>
{
public:
    static void find(MethylOnBridgeCBiCMu *target);

//    using MonoTypical::MonoTypical;
    DesMethylFromBridge(SpecificSpec *target) : MonoTypical(target) {}

    double rate() const { return 1e4; }
    void doIt();

    std::string name() const override { return "desorption methyl from bridge"; }
};

#endif // DES_METHYL_FROM_BRIDGE_H
