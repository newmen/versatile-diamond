#ifndef BRIDGE_CRH_H
#define BRIDGE_CRH_H

#include "../base/bridge_cri.h"
#include "../base_specific.h"

class BridgeCRh : public BaseSpecific<DependentSpec<BaseSpec>, BRIDGE_CRh, 1>
{
public:
    static void find(BridgeCRi *parent);

    BridgeCRh(ParentSpec *parent) : BaseSpecific(parent) {}

#ifdef PRINT
    const std::string name() const override { return "bridge(cr: H)"; }
#endif // PRINT

protected:
    void findAllReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // BRIDGE_CRH_H
