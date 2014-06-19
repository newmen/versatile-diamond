#ifndef TWO_BRIDGES_H
#define TWO_BRIDGES_H

#include "../base.h"

class TwoBridges : public Base<DependentSpec<ParentSpec, 3>, TWO_BRIDGES, 1>
{
public:
    static void find(Atom *anchor);

    TwoBridges(ParentSpec **parents) : Base(parents) {}

#ifdef PRINT
    const char *name() const final;
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
