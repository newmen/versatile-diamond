#include "surface_activation.h"

const ushort SurfaceActivation::__hToActives[] =
{
    // TODO: проверить правила перехода (15 :: C:i=) в (16 :: *C=), в настоящий момент руками изменена цифра!
    28, 2, 2, 1, 5, 5, 5, 8, 8, 8,
    10, 12, 13, 13, 11, 16, 17, 17, 16, 19,
    21, 21, 21, 23, 24, 26, 27, 13, 2, 30,
    13, 29, 32
};

const ushort SurfaceActivation::__hOnAtoms[] =
{
    2, 1, 0, 2, 1, 0, 1, 1, 0, 1,
    3, 2, 1, 0, 3, 2, 1, 0, 2, 0,
    1, 0, 1, 0, 0, 3, 2, 1, 1, 2,
    1, 3, 0
};

void SurfaceActivation::find(Atom *anchor)
{
    short dn = delta(anchor, __hOnAtoms);
    Ubiquitous::find<SurfaceActivation>(anchor, dn);
}

short SurfaceActivation::toType(ushort type) const
{
    return __hToActives[type];
}
