#ifndef TWO_BRIDGES_H
#define TWO_BRIDGES_H

#include "bridge.h"

class TwoBridges : public Base<AtomsSwapWrapper<DependentSpec<ParentSpec, 3>>, TWO_BRIDGES, 1>
{
public:
    static void find(Bridge *parent);

    TwoBridges(ushort from, ushort to, ParentSpec **parents) : Base(from, to, parents) {}

#ifdef PRINT
    std::string name() const override { return "two bridges"; }
#endif // PRINT

protected:
    void findAllChildren() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // TWO_BRIDGES_H
