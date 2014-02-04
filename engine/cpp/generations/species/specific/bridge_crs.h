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
    std::string name() const override { return "bridge(cr: *)"; }
#endif // PRINT

protected:
    void findAllChildren() override;
    void findAllTypicalReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // BRIDGE_CRS_H
