#ifndef DIMER_H
#define DIMER_H

#include "../../species/dependent_spec.h"
using namespace vd;

class Dimer : public DependentSpec<2>
{
public:
    static void find(Atom *anchor);

//    using DependentSpec::DependentSpec;
    Dimer(ushort type, BaseSpec **parents);

#ifdef PRINT
    std::string name() const override { return "dimer"; }
#endif // PRINT

    void findChildren() override;

private:
    static void checkAndAdd(Atom *anchor, Atom *neighbour);
    static Atom *checkAndFind(Atom *anchor);
};

#endif // DIMER_H
