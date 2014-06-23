#ifndef BRIDGE_CRS_H
#define BRIDGE_CRS_H

#include "../base/bridge_cri.h"
#include "../specific.h"

class BridgeCRs : public Specific<Base<DependentSpec<ParentSpec>, BRIDGE_CRs, 1>>
{
public:
    static void find(BridgeCRi *parent);

    BridgeCRs(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllChildren() final;
    void findAllTypicalReactions() final;

    const ushort *indexes() const final { return __indexes; }
    const ushort *roles() const final { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // BRIDGE_CRS_H
