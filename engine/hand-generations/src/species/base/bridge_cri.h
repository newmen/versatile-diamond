#ifndef BRIDGE_CRI_H
#define BRIDGE_CRI_H

#include "bridge.h"

class BridgeCRi : public Base<AtomsSwapWrapper<DependentSpec<ParentSpec>>, BRIDGE_CRi, 1>
{
public:
    static void find(Bridge *parent);

    BridgeCRi(ushort fromIndex, ushort toIndex, ParentSpec *parent) : Base(fromIndex, toIndex, parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllChildren() final;

    const ushort *indexes() const final { return __indexes; }
    const ushort *roles() const final { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // BRIDGE_CRI_H
