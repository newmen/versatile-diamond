#include "../../generations/atoms/c.h"
#include "../../generations/phases/diamond.h"
#include "../support/corrected_types.h"

#ifdef DEBUG

class OpenDiamond : public Diamond
{
public:
    typedef Neighbours<4> FN;

    static const dim3 SIZES;
    OpenDiamond(uint height = 4) : Diamond(SIZES, height) {}

    Atom *atom(const int3 &coords) { return atoms()[coords]; }

    FN neighbours110(const Atom *atom)
    {
        TN f110 = front_110(atom);
        TN c110 = cross_110(atom);
        Atom *nbrs[4] = { f110[0], f110[1], c110[0], c110[1] };
        return FN(nbrs);
    }

    FN neighbours100(const Atom *atom)
    {
        TN f100 = front_100(atom);
        TN c100 = cross_100(atom);
        Atom *nbrs[4] = { f100[0], f100[1], c100[0], c100[1] };
        return FN(nbrs);
    }

    bool isBonded(const int3 &a, const int3 &b)
    {
        Atom *aa = atom(a), *bb = atom(b);
        return aa->hasBondWith(bb) && bb->hasBondWith(aa);
    }
};


class OpenC : public C
{
public:
    uint activesNum() const { return C::actives(); }
};

#endif // DEBUG
