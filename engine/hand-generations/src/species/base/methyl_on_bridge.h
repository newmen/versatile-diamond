#ifndef METHYL_ON_BRIDGE_H
#define METHYL_ON_BRIDGE_H

#include "bridge.h"

class MethylOnBridge : public Base<AdditionalAtomsWrapper<DependentSpec<ParentSpec>, 1>, METHYL_ON_BRIDGE, 2>
{
public:
    static void find(Bridge *target);

    MethylOnBridge(Atom *additionalAtom, ParentSpec *parent) : Base(additionalAtom, parent) {}

#if defined(PRINT) || defined(SERIALIZE)
    const char *name() const override;
#endif // PRINT || SERIALIZE

protected:
    void findAllChildren() final;
};

#endif // METHYL_ON_BRIDGE_H
