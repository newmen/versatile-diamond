#ifndef SPECIFIC_SPEC_H
#define SPECIFIC_SPEC_H

#include "base_spec.h"

namespace vd
{

template <ushort ATOMS_NUM>
class SpecificSpec : public ConcreteBaseSpec<ATOMS_NUM>
{

public:
//    SpecificSpec(ushort type, BaseSpec *parent, Atom **atoms);
    using ConcreteBaseSpec<ATOMS_NUM>::ConcreteBaseSpec;
};

}

#endif // SPECIFIC_SPEC_H
