#ifndef BRIDGE_WITH_DIMER_CDLi_H
#define BRIDGE_WITH_DIMER_CDLi_H

#include "../base/bridge_with_dimer.h"
#include "../base_specific.h"

class BridgeWithDimerCDLi : public BaseSpecific<DependentSpec<ParentSpec>, BRIDGE_WITH_DIMER_CDLi, 1>
{
public:
    static void find(BridgeWithDimer *parent);

    BridgeWithDimerCDLi(ParentSpec *parent) : BaseSpecific(parent) {}

#ifdef PRINT
    std::string name() const override { return "bridge_with_dimer(cdl: i)"; }
#endif // PRINT

protected:
    void findAllChildren() override;
    void findAllReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // BRIDGE_WITH_DIMER_CDLi_H
