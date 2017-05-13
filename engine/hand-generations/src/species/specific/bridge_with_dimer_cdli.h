#ifndef BRIDGE_WITH_DIMER_CDLi_H
#define BRIDGE_WITH_DIMER_CDLi_H

#include "../base/bridge_with_dimer.h"
#include "../specific.h"

class BridgeWithDimerCDLi : public Specific<Base<DependentSpec<ParentSpec>, BRIDGE_WITH_DIMER_CDLi, 1>>
{
public:
    static void find(BridgeWithDimer *parent);

    BridgeWithDimerCDLi(ParentSpec *parent) : Specific(parent) {}

#if defined(PRINT) || defined(SPEC_PRINT) || defined(JSONLOG)
    const char *name() const override;
#endif // PRINT || SPEC_PRINT || JSONLOG

protected:
    void findAllChildren() final;
    void findAllTypicalReactions() final;
};

#endif // BRIDGE_WITH_DIMER_CDLi_H
