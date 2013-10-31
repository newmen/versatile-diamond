#ifndef BRIDGE_CTSI_H
#define BRIDGE_CTSI_H

#include "../../species/specific_spec.h"
using namespace vd;

#include "../base_specs/bridge.h"

class BridgeCTsi : public SpecificSpec
{
public:
    static void find(Bridge *parent);

//    using SpecificSpec::SpecificSpec;
    BridgeCTsi(ushort type, BaseSpec *parent) : SpecificSpec(type, parent) {}

#ifdef PRINT
    std::string name() const override { return "bridge(ct: *, ct: i)"; }
#endif // PRINT

    void findChildren() override;
};

#endif // BRIDGE_CTSI_H
