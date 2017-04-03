#ifndef NDEBUG

#include <atoms/c.h>
#include <phases/diamond.h>
#include <phases/behavior_tor.h>
#include "../support/corrected_types.h"

class OpenDiamond : public Diamond
{
    enum : ushort { DEFAULT_HEIGHT = 4 };

public:
    typedef Neighbours<4> FN;

    static const dim3 SIZES;
    OpenDiamond(uint height = DEFAULT_HEIGHT) : OpenDiamond(SIZES, height) {}
    OpenDiamond(const dim3 &sizes, uint height = DEFAULT_HEIGHT) : Diamond(sizes, new BehaviorTor, height) {}

    Atom *atom(const int3 &coords) { return atoms()[coords]; }

    FN neighbours110(const Atom *atom) // for what???
    {
        TN f110 = front_110(atom);
        TN c110 = cross_110(atom);
        Atom *nbrs[4] = { f110[0], f110[1], c110[0], c110[1] };
        return FN(nbrs);
    }

    FN neighbours100(const Atom *atom) // for what???
    {
        TN f100 = front_100(atom);
        TN c100 = cross_100(atom);
        Atom *nbrs[4] = { f100[0], f100[1], c100[0], c100[1] };
        return FN(nbrs);
    }

    bool isBonded(const int3 &a, const int3 &b)
    {
        Atom *aa = atom(a), *bb = atom(b);
        if (aa->hasBondWith(bb))
        {
            assert(bb->hasBondWith(aa));  // !!
            return true;
        }
        else
        {
            return false;
        }
    }
};


class OpenC : public C
{
public:
    uint activesNum() const { return C::actives(); }
};

#endif // NDEBUG
