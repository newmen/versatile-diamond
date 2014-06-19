#ifndef BRIDGE_CRH_H
#define BRIDGE_CRH_H

#include "../base/bridge_cri.h"
#include "../specific.h"

class BridgeCRh : public Specific<Base<DependentSpec<BaseSpec>, BRIDGE_CRh, 1>>
{
public:
    static void find(BridgeCRi *parent);

    BridgeCRh(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllTypicalReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // BRIDGE_CRH_H
