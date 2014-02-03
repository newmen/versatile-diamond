#ifndef BRIDGE_CRI_H
#define BRIDGE_CRI_H

#include "bridge.h"

class BridgeCRi : public Base<AtomsSwapWrapper<DependentSpec<ParentSpec>>, BRIDGE_CRi, 1>
{
public:
    static void find(Bridge *parent);

    BridgeCRi(ushort fromIndex, ushort toIndex, ParentSpec *parent) : Base(fromIndex, toIndex, parent) {}

#ifdef PRINT
    std::string name() const override { return "bridge(cr: i)"; }
#endif // PRINT

protected:
    void findAllChildren() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // BRIDGE_CRI_H
