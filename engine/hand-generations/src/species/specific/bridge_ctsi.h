#ifndef BRIDGE_CTSI_H
#define BRIDGE_CTSI_H

#include "../base/bridge.h"
#include "../specific.h"

class BridgeCTsi : public Specific<Base<DependentSpec<BaseSpec>, BRIDGE_CTsi, 1>>
{
public:
    static void find(Bridge *parent);

    BridgeCTsi(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllTypicalReactions() final;
};

#endif // BRIDGE_CTSI_H
