#ifndef BRIDGE_CRS_H
#define BRIDGE_CRS_H

#include "../base/bridge_cri.h"
#include "../specific.h"

class BridgeCRs : public Specific<Base<DependentSpec<ParentSpec>, BRIDGE_CRs, 1>>
{
public:
    static void find(BridgeCRi *parent);

    BridgeCRs(ParentSpec *parent) : Specific(parent) {}

#if defined(PRINT) || defined(SPEC_PRINT) || defined(JSONLOG)
    const char *name() const override;
#endif // PRINT || SPEC_PRINT || JSONLOG

protected:
    void findAllChildren() final;
    void findAllTypicalReactions() final;
};

#endif // BRIDGE_CRS_H
