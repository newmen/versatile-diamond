#ifndef TWO_BRIDGES_H
#define TWO_BRIDGES_H

#include "../empty.h"

class TwoBridges : public Empty<DependentSpec<ParentSpec, 3>, TWO_BRIDGES>
{
public:
    static void find(Atom *anchor);

    TwoBridges(ParentSpec **parents) : Empty(parents) {}

#ifdef PRINT
    std::string name() const override { return "two bridges"; }
#endif // PRINT

protected:
    void findAllChildren() override;
};

#endif // TWO_BRIDGES_H
