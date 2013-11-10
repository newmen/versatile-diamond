#ifndef BRIDGE_CRS_H
#define BRIDGE_CRS_H

#include "../../species/specific_spec.h"
#include "../../species/atoms_swap_wrapper.h"
using namespace vd;

#include "../base_specs/bridge.h"

class BridgeCRs : public AtomsSwapWrapper<SpecificSpec>
{
public:
    static void find(Bridge *parent);

//    using AtomsSwapWrapper<SpecificSpec>::AtomsSwapWrapper;
    BridgeCRs(ushort fromIndex, ushort toIndex, ushort type, BaseSpec *parent) :
        AtomsSwapWrapper<SpecificSpec>(fromIndex, toIndex, type, parent) {}

#ifdef PRINT
    std::string name() const override { return "bridge(cr: *)"; }
#endif // PRINT

    void findChildren() override;
};

#endif // BRIDGE_CRS_H
