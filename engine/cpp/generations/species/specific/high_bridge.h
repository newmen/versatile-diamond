#ifndef HIGH_BRIDGE_H
#define HIGH_BRIDGE_H

#include "../base/bridge.h"
#include "../base_specific.h"

// TODO: wrong dependency tree (from analyzer), because high bridge is not dependent from methyl on bridge
class HighBridge :
        public BaseSpecific<AdditionalAtomsWrapper<DependentSpec<ParentSpec>, 1>, HIGH_BRIDGE, 2>
{
public:
    static void find(Bridge *parent);

    HighBridge(Atom *additionalAtom, ParentSpec *parent) : BaseSpecific(additionalAtom, parent) {}

#ifdef PRINT
    std::string name() const override { return "high bridge"; }
#endif // PRINT

protected:
    void findAllChildren() override;
    void findAllReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[2];
    static const ushort __roles[2];
};

#endif // HIGH_BRIDGE_H
