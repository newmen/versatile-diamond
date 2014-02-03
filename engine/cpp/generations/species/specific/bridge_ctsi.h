#ifndef BRIDGE_CTSI_H
#define BRIDGE_CTSI_H

#include "../base/bridge.h"
#include "../base_specific.h"

class BridgeCTsi : public BaseSpecific<DependentSpec<BaseSpec>, BRIDGE_CTsi, 1>
{
public:
    static void find(Bridge *parent);

    BridgeCTsi(ParentSpec *parent) : BaseSpecific(parent) {}

#ifdef PRINT
    std::string name() const override { return "bridge(ct: *, ct: i)"; }
#endif // PRINT

protected:
    void findAllReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // BRIDGE_CTSI_H
