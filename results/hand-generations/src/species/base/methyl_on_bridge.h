#ifndef METHYL_ON_BRIDGE_H
#define METHYL_ON_BRIDGE_H

#include "bridge.h"

class MethylOnBridge : public Base<AdditionalAtomsWrapper<DependentSpec<ParentSpec>, 1>, METHYL_ON_BRIDGE, 2>
{
public:
    static void find(Bridge *target);

    MethylOnBridge(Atom *additionalAtom, ParentSpec *parent) : Base(additionalAtom, parent) {}

#ifdef PRINT
    const char *name() const override;
#endif // PRINT

protected:
    void findAllChildren() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[2];
    static const ushort __roles[2];
};

#endif // METHYL_ON_BRIDGE_H
