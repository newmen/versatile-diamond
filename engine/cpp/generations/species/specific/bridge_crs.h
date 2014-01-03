#ifndef BRIDGE_CRS_H
#define BRIDGE_CRS_H

#include "../base/bridge.h"
#include "../base_specific.h"

class BridgeCRs :
        public BaseSpecific<AtomsSwapWrapper<DependentSpec<ParentSpec>>, BRIDGE_CRs, 1>
{
public:
    static void find(Bridge *parent);

    BridgeCRs(ushort fromIndex, ushort toIndex, ParentSpec *parent) : BaseSpecific(fromIndex, toIndex, parent) {}

#ifdef PRINT
    const std::string name() const override { return "bridge(cr: *)"; }
#endif // PRINT

protected:
    void findAllChildren() override;
    void findAllReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // BRIDGE_CRS_H
