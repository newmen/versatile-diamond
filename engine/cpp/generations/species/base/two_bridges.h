#ifndef TWO_BRIDGES_H
#define TWO_BRIDGES_H

#include "../base.h"

class TwoBridges : public Base<AdditionalAtomsWrapper<DependentSpec<ParentSpec, 2>, 1>, TWO_BRIDGES, 3>
{
public:
    static void find(Atom *anchor);

    TwoBridges(Atom *additionalAtom, ParentSpec **parents) : Base(additionalAtom, parents) {}

#ifdef PRINT
    std::string name() const override { return "two bridges"; }
#endif // PRINT

    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

protected:
    void findAllChildren() override;

private:
    static ushort __indexes[3];
    static ushort __roles[3];
};

#endif // TWO_BRIDGES_H
