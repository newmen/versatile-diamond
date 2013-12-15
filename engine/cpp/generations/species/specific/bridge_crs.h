#ifndef BRIDGE_CRS_H
#define BRIDGE_CRS_H

#include "../base/bridge.h"
#include "../specific.h"

class BridgeCRs :
        public Specific<AtomsSwapWrapper<DependentSpec<ParentSpec>>, BRIDGE_CRs, 1>
{
public:
    static void find(Bridge *parent);

    BridgeCRs(ushort fromIndex, ushort toIndex, ParentSpec *parent) : Specific(fromIndex, toIndex, parent) {}

#ifdef PRINT
    std::string name() const override { return "bridge(cr: *)"; }
#endif // PRINT

    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

protected:
    void findAllChildren() override;
    void findAllReactions() override;

private:
    static ushort __indexes[1];
    static ushort __roles[1];
};

#endif // BRIDGE_CRS_H
