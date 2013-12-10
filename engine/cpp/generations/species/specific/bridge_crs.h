#ifndef BRIDGE_CRS_H
#define BRIDGE_CRS_H

#include "../../../species/atoms_swap_wrapper.h"
#include "../specific.h"
#include "../base/bridge.h"

class BridgeCRs : public Specific<BRIDGE_CRs, 1, AtomsSwapWrapper<SpecificSpec>>
{
public:
    static void find(Bridge *parent);

//    using Specific::Specific;
    BridgeCRs(ushort fromIndex, ushort toIndex, BaseSpec *parent) : Specific(fromIndex, toIndex, parent) {}

#ifdef PRINT
    std::string name() const override { return "bridge(cr: *)"; }
#endif // PRINT

protected:
    void findAllChildren() override;
    void findAllReactions() override;

    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

private:
    static ushort __indexes[1];
    static ushort __roles[1];
};

#endif // BRIDGE_CRS_H
