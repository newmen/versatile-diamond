#ifndef BRIDGE_CRH_H
#define BRIDGE_CRH_H

#include "../base/bridge_cri.h"
#include "../specific.h"

class BridgeCRh : public Specific<Base<DependentSpec<BaseSpec>, BRIDGE_CRh, 1>>
{
public:
    static void find(BridgeCRi *parent);

    BridgeCRh(ParentSpec *parent) : Specific(parent) {}

#if defined(PRINT) || defined(SERIALIZE)
    const char *name() const override;
#endif // PRINT || SERIALIZE

protected:
    void findAllTypicalReactions() final;
};

#endif // BRIDGE_CRH_H
