#ifndef HIGH_BRIDGE_H
#define HIGH_BRIDGE_H

#include "../base/bridge.h"
#include "../specific.h"

// TODO: wrong dependency tree (from analyzer), because high bridge is not dependent from methyl on bridge
class HighBridge : public Specific<AdditionalAtomsWrapper<DependentSpec<BaseSpec>, 1>, HIGH_BRIDGE, 2>
{
public:
    static void find(Bridge *parent);

    HighBridge(Atom *additionalAtom, ParentSpec *parent) : Specific(additionalAtom, parent) {}

#ifdef PRINT
    std::string name() const override { return "high bridge"; }
#endif // PRINT

    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

protected:
    void findAllReactions() override;

private:
    static ushort __indexes[2];
    static ushort __roles[2];
};

#endif // HIGH_BRIDGE_H
