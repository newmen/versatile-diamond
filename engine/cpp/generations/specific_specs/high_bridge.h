#ifndef HIGH_BRIDGE_H
#define HIGH_BRIDGE_H

#include "../../species/specific_spec.h"
#include "../../species/additional_atoms_wrapper.h"
using namespace vd;

#include "../base_specs/bridge.h"

// TODO: wrong dependency tree, because high bridge is not dependent from methyl on bridge
class HighBridge : public AdditionalAtomsWrapper<SpecificSpec, 1>
{
public:
    static void find(Bridge *target);

//    using AdditionalAtomsWrapper<SpecificSpec, 1>::AdditionalAtomsWrapper;
    HighBridge(Atom **additionalAtoms, ushort type, BaseSpec *parent) :
        AdditionalAtomsWrapper<SpecificSpec, 1>(additionalAtoms, type, parent) {}

#ifdef PRINT
    std::string name() const override { return "high bridge"; }
#endif // PRINT

    void findChildren() override;

};

#endif // HIGH_BRIDGE_H
