#include "defaultcompositionbuilder.h"

Atom *DefaultCompositionBuilder::build(const Crystal *crystal, const uint3 &coords) const
{
    char name[] = "C";
    return new Atom(name, 4, lattice(crystal, coords));
}
