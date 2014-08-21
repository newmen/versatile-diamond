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
};

#endif // BRIDGE_CRS_H
