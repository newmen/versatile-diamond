#ifndef COMPOSITIONBUILDER_H
#define COMPOSITIONBUILDER_H

#include "common.h"
#include "atom.h"
#include "crystal.h"

namespace vd
{

class CompositionBuilder
{
public:
    virtual ~CompositionBuilder() {}

    virtual Atom *build(const Crystal *crystal, const uint3 &coords) const = 0;

protected:
    CompositionBuilder() {}

    Lattice *lattice(const Crystal *crystal, const uint3 &coords) const;
};

}

#endif // COMPOSITIONBUILDER_H
