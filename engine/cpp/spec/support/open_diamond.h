class OpenDiamond : public Diamond
{
public:
    typedef Neighbours<4> FN;

    OpenDiamond(uint height = 4) : Diamond(dim3(10, 10, 10), height) {}

    Atom *atom(const int3 &coords) { return atoms()[coords]; }

    FN neighbours110(const Atom *atom)
    {
        DiamondRelations::TN f110 = front_110(atom);
        DiamondRelations::TN c110 = cross_110(atom);
        Atom *nbrs[4] = { f110[0], f110[1], c110[0], c110[1] };
        return FN(nbrs);
    }

    FN neighbours100(const Atom *atom)
    {
        DiamondRelations::TN f100 = front_100(atom);
        DiamondRelations::TN c100 = cross_100(atom);
        Atom *nbrs[4] = { f100[0], f100[1], c100[0], c100[1] };
        return FN(nbrs);
    }

    bool isBonded(const int3 &a, const int3 &b)
    {
        Atom *aa = atom(a), *bb = atom(b);
        return aa->hasBondWith(bb) && bb->hasBondWith(aa);
    }
};
