#include "reaction_deactivation.h"
#include "../../handbook.h"

const ushort ReactionDeactivation::__activesOnAtoms[] =
{
    0, 1, 2, 0, 0, 1, 0, 0, 1, 0, 0, 1, 2, 3, 0, 0, 1, 2, 0, 0, 0, 1, 0, 0, 0, 0, 1, 2, 1, 1, 2, 0
};

const ushort ReactionDeactivation::__activesToH[] =
{
    0, 3, 1, 3, 4, 6, 6, 7, 9, 9, 10, 14, 11, 12, 14, 15, 18, 16, 18, 19, 20, 22, 22, 23, 24, 25, 25, 26, 0, 31, 29, 31
};

void ReactionDeactivation::find(Atom *anchor)
{
    if (anchor->is(26)) return;

    short dn = delta(anchor, __activesOnAtoms);
    if (dn > 0)
    {
        Handbook::mc().addMul<SURFACE_DEACTIVATION>(new ReactionDeactivation(anchor), dn);
    }
}

short ReactionDeactivation::toType(ushort type) const
{
    return __activesToH[type];
}

void ReactionDeactivation::remove()
{
    short dn = delta(target(), __activesOnAtoms);
    assert(dn < 0);
    Handbook::mc().removeMul<SURFACE_DEACTIVATION>(this, -dn);
}
