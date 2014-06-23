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

    const ushort *indexes() const final { return __indexes; }
    const ushort *roles() const final { return __roles; }

private:
    static const ushort __indexes[2];
    static const ushort __roles[2];
};

#endif // HIGH_BRIDGE_H
