#ifndef ATOM_INFO_H
#define ATOM_INFO_H

#include <string>
#include "../../atoms/atom.h"

namespace vd
{

class AtomInfo
{
    const Atom *const _atom;
    uint _noBond = 0;

    friend class std::hash<AtomInfo>;

public:
    explicit AtomInfo(const Atom *atom);

    bool operator == (const AtomInfo &other) const;

    void incNoBond();

    const char *type() const;
    float3 coords() const;
    template <class D> std::string options() const;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class D>
std::string AtomInfo::options() const
{
    bool isBtm = D::isBottom(_atom);

    int hc = _atom->hCount();
    if (hc == 0 || isBtm)
    {
        hc = -1;
    }

    std::stringstream ss;
    ss << " HCOUNT=" << hc;

    ushort ac = isBtm ? _atom->valence() - _atom->bonds() : _atom->actives();
    ac += _noBond;
    if (ac > 0)
    {
        ss << " CHG=-" << ac;
    }

    return ss.str();
}

}

//////////////////////////////////////////////////////////////////////////////////////

namespace std
{

using namespace vd;

template <>
struct hash<AtomInfo>
{
    std::size_t operator () (const AtomInfo &ai) const
    {
        return reinterpret_cast<std::size_t>(ai._atom);
    }
};

}

#endif // ATOM_INFO_H
