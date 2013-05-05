#include "compositionbuilder.h"

namespace vd
{

Lattice *CompositionBuilder::lattice(const Crystal *crystal, const uint3 &coords) const
{
    return new Lattice(crystal, coords);
}

}
