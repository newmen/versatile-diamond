#include "surface_deactivation.h"

const ushort SurfaceDeactivation::__activesToH[] =
{
    0, 3, 1, 3, 4, 6, 6, 7, 9, 9,
    10, 11, 12, 13, 14, 15, 18, 16, 18, 19,
    20, 22, 22, 23, 24, 25, 26, 27, 0, 29,
    30, 31
};

const ushort SurfaceDeactivation::__activesOnAtoms[] =
{
    0, 1, 2, 0, 0, 1, 0, 0, 1, 0,
    0, 0, 0, 0, 0, 0, 1, 2, 0, 0,
    0, 1, 0, 0, 0, 0, 0, 0, 1, 0,
    0, 0
};

void SurfaceDeactivation::find(Atom *anchor)
{
    short dn = delta(anchor, __activesOnAtoms);
    Ubiquitous::find<SurfaceDeactivation>(anchor, dn);
}

short SurfaceDeactivation::toType(ushort type) const
{
    return __activesToH[type];
}
