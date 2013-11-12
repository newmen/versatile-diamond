#ifndef HIGH_BRIDGE_H
#define HIGH_BRIDGE_H

#include "../../../species/additional_atoms_wrapper.h"
#include "../specific.h"
#include "../base/bridge.h"

// TODO: wrong dependency tree (from analyzer), because high bridge is not dependent from methyl on bridge
class HighBridge : public Specific<HIGH_BRIDGE, 2, AdditionalAtomsWrapper<SpecificSpec, 1>>
{
public:
    static void find(Bridge *parent);

//    using Specific<HIGH_BRIDGE, 2, AdditionalAtomsWrapper<SpecificSpec, 1>>::Specific;
    HighBridge(Atom **additionalAtoms, BaseSpec *parent) : Specific(additionalAtoms, parent) {}

#ifdef PRINT
    std::string name() const override { return "high bridge"; }
#endif // PRINT

    void findChildren() override;

protected:
    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

private:
    static ushort __indexes[2];
    static ushort __roles[2];
};

#endif // HIGH_BRIDGE_H
