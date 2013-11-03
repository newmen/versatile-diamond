#include "surface_activation.h"
#include "../../handbook.h"

const ushort SurfaceActivation::__hToActives[] =
{
    // TODO: проверить правила перехода C:i= в *C= (в настоящий момент руками изменена цифра!)
    28, 2, 2, 1, 5, 5, 5, 8, 8, 8,
    10, 12, 13, 13, 11, 16, 17, 17, 16, 19,
    21, 21, 21, 23, 24, 26, 27, 13, 2, 30,
    13, 29
};

const ushort SurfaceActivation::__hOnAtoms[] =
{
    2, 1, 0, 2, 1, 0, 1, 1, 0, 1,
    3, 2, 1, 0, 3, 2, 1, 0, 2, 0,
    1, 0, 1, 0, 0, 3, 2, 1, 1, 2,
    1, 3
};

void SurfaceActivation::find(Atom *anchor)
{
    if (anchor->is(25)) return; // except dependent reaction

    if (anchor->type() != NO_VALUE && anchor->prevIs(25))
    {
        ushort n = __hOnAtoms[anchor->type()];
        if (n > 0)
        {
            Handbook::mc.addMul<SURFACE_ACTIVATION>(new SurfaceActivation(anchor), n);
        }
    }
    else
    {
        short dn = delta(anchor, __hOnAtoms);
        if (dn > 0)
        {
            Handbook::mc.addMul<SURFACE_ACTIVATION>(new SurfaceActivation(anchor), dn);
        }
        else if (dn < 0)
        {
            SurfaceActivation removableTemplate(anchor);
            Handbook::mc.removeMul<SURFACE_ACTIVATION>(&removableTemplate, -dn);
        }
    }
}

short SurfaceActivation::toType(ushort type) const
{
    return __hToActives[type];
}
