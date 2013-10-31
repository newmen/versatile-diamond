#include "surface_deactivation.h"
#include "../../handbook.h"

const ushort SurfaceDeactivation::__activesToH[] =
{
    0, 3, 1, 3, 4, 6, 6, 7, 9, 9, 10, 14, 11, 12, 14, 15, 18, 16, 18, 19, 20, 22, 22, 23, 24, 25, 25, 26, 0, 31, 29, 31
};

const ushort SurfaceDeactivation::__activesOnAtoms[] =
{
    0, 1, 2, 0, 0, 1, 0, 0, 1, 0, 0, 1, 2, 3, 0, 0, 1, 2, 0, 0, 0, 1, 0, 0, 0, 0, 1, 2, 1, 1, 2, 0
};

void SurfaceDeactivation::find(Atom *anchor)
{
    if (anchor->is(26)) return;

    short dn = delta(anchor, __activesOnAtoms);
    if (dn > 0)
    {
        Handbook::mc.addMul<SURFACE_DEACTIVATION>(new SurfaceDeactivation(anchor), dn);
    }
    else if (dn < 0)
    {
        SurfaceDeactivation removableTemplate(anchor);
        Handbook::mc.removeMul<SURFACE_DEACTIVATION>(&removableTemplate, -dn);
    }
}

short SurfaceDeactivation::toType(ushort type) const
{
    return __activesToH[type];
}
