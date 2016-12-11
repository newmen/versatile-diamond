#ifndef BRIDGE_CRI_H
#define BRIDGE_CRI_H

#include "bridge.h"

class BridgeCRi : public Base<DependentSpec<ParentSpec>, BRIDGE_CRi, 1>
{
public:
    static void find(Bridge *parent);

    BridgeCRi(ParentSpec *parent) : Base(parent) {}

#if defined(PRINT) || defined(SERIALIZE)
    const char *name() const override;
#endif // PRINT || SERIALIZE

protected:
    void findAllChildren() final;
};

#endif // BRIDGE_CRI_H
