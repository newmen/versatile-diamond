#ifndef ATOM_BUILDER_H
#define ATOM_BUILDER_H

#include "atom.h"

namespace vd
{

class AtomBuilder
{
public:
    virtual Atom *build(uint type) = 0;
};

}

#endif // ATOM_BUILDER_H
