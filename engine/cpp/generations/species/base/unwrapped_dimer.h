#ifndef UNWRAPPED_DIMER_H
#define UNWRAPPED_DIMER_H

#include "../../../tools/typed.h"
#include "../../../species/dependent_spec.h"
using namespace vd;

#include "../../handbook.h"

class UnwrappedDimer : public Typed<DependentSpec<2>, DIMER>
{
public:
    UnwrappedDimer(BaseSpec **parents) : Typed(parents) {}

#ifdef PRINT
    std::string name() const override { return "dimer"; }
#endif // PRINT

    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

protected:
    void findAllChildren() override { assert(false); } // TODO: !!!

private:
    static ushort __indexes[2];
    static ushort __roles[2];
};

#endif // UNWRAPPED_DIMER_H
