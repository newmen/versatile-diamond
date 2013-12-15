#ifndef METHYL_ON_BRIDGE_H
#define METHYL_ON_BRIDGE_H

#include "../base.h"
#include "bridge.h"

class MethylOnBridge : public Base<AdditionalAtomsWrapper<DependentSpec<ParentSpec>, 1>, METHYL_ON_BRIDGE, 2>
{
public:
    static void find(Bridge *target);

    MethylOnBridge(Atom **additionalAtoms, ParentSpec *parent) : Base(additionalAtoms, parent) {}

#ifdef PRINT
    std::string name() const override { return "methyl on bridge"; }
#endif // PRINT

    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

protected:
    void findAllChildren() override;

private:
    static ushort __indexes[2];
    static ushort __roles[2];
};

#endif // METHYL_ON_BRIDGE_H
