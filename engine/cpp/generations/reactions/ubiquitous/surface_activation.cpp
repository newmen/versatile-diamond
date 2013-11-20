#include "surface_activation.h"

const ushort SurfaceActivation::__hToActives[] =
{
    // TODO: проверить правила перехода C:i= в *C= (в настоящий момент руками изменена цифра!)
    // TODO: для видов, что перекрывают повсеместные реакции генерировать собственные числа
    28, 2, 2, 1, 5, 5, 5, 8, 8, 8,
    10, 11, 12, 13, 14, 16, 17, 17, 16, 19,
    21, 21, 21, 23, 24, 25, 26, 27, 2, 29,
    30, 31
};

const ushort SurfaceActivation::__hOnAtoms[] =
{
    // TODO: для видов, что перекрывают повсеместные реакции генерировать нули
    2, 1, 0, 2, 1, 0, 1, 1, 0, 1,
    0, 0, 0, 0, 0, 2, 1, 0, 2, 0,
    1, 0, 1, 0, 0, 0, 0, 0, 1, 0,
    0, 0
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
