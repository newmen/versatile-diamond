#ifndef METHYL_ON_BRIDGE_CBI_CMU_H
#define METHYL_ON_BRIDGE_CBI_CMU_H

#include "../../species/specific_spec.h"
using namespace vd;

#include "../base_specs/methyl_on_bridge.h"

class MethylOnBridgeCBiCMu : public SpecificSpec
{
public:
    static void find(MethylOnBridge *parent);

//    using SpecificSpec::SpecificSpec;
    MethylOnBridgeCBiCMu(ushort type, BaseSpec *parent) : SpecificSpec(type, parent) {}

#ifdef PRINT
    std::string name() const override { return "methyl_on_bridge(cb: i, cm: u)"; }
#endif // PRINT

    void findChildren() override;
};

#endif // METHYL_ON_BRIDGE_CBI_CMU_H
