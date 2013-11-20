#ifndef METHYL_ON_BRIDGE_H
#define METHYL_ON_BRIDGE_H

#include "../../../species/additional_atoms_wrapper.h"
#include "../dependent.h"
#include "bridge.h"

class MethylOnBridge : public Dependent<METHYL_ON_BRIDGE, 2, AdditionalAtomsWrapper<DependentSpec<1>, 1>>
{
public:
    static void find(Bridge *target);

//    using Dependent<METHYL_ON_BRIDGE, 2, AdditionalAtomsWrapper<DependentSpec<1>, 1>>::Dependent;
    MethylOnBridge(Atom **additionalAtoms, BaseSpec **parents) : Dependent(additionalAtoms, parents) {}

#ifdef PRINT
    std::string name() const override { return "methyl on bridge"; }
#endif // PRINT

    void findAllChildren() override;

protected:
    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

private:
    static ushort __indexes[2];
    static ushort __roles[2];
};

#endif // METHYL_ON_BRIDGE_H
