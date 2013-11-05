#ifndef METHYL_ON_BRIDGE_H
#define METHYL_ON_BRIDGE_H

#include "../../species/dependent_spec.h"
#include "../../species/additional_atoms_wrapper.h"
using namespace vd;

#include "bridge.h"

class MethylOnBridge : public AdditionalAtomsWrapper<DependentSpec<1>, 1>
{
public:
    static void find(Bridge *target);

//    using AdditionalAtomsWrapper<DependentSpec<1>, 1>::AdditionalAtomsWrapper;
    MethylOnBridge(Atom **additionalAtoms, ushort type, BaseSpec **parents) :
        AdditionalAtomsWrapper<DependentSpec<1>, 1>(additionalAtoms, type, parents) {}

#ifdef PRINT
    std::string name() const override { return "methyl on bridge"; }
#endif // PRINT

    void findChildren() override;

};

#endif // METHYL_ON_BRIDGE_H
