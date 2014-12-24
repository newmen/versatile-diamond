#ifndef TWO_BRIDGES_H
#define TWO_BRIDGES_H

#include "../base.h"

class TwoBridges : public Base<DependentSpec<ParentSpec, 3>, TWO_BRIDGES, 2>
{
public:
    static void find(Atom *anchor);

    TwoBridges(ParentSpec **parents) : Base(parents) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllChildren() final;
};

#endif // TWO_BRIDGES_H
