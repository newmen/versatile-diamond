#ifndef HIGH_BRIDGE_H
#define HIGH_BRIDGE_H

#include "../base/bridge.h"
#include "../specific.h"

class HighBridge : public Specific<Base<AdditionalAtomsWrapper<DependentSpec<ParentSpec>, 1>, HIGH_BRIDGE, 2>>
{
public:
    static void find(Bridge *parent);

    HighBridge(Atom *additionalAtom, ParentSpec *parent) : Specific(additionalAtom, parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllChildren() final;
    void findAllTypicalReactions() final;
};

#endif // HIGH_BRIDGE_H
