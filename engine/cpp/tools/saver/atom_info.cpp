#include "atom_info.h"
#include <sstream>

namespace vd
{

AtomInfo::AtomInfo(const Atom *atom) : _atom(atom)
{
}

bool AtomInfo::operator ==(const AtomInfo &other) const
{
    return _atom == other._atom;
}

const char *AtomInfo::type() const
{
    return _atom->name();
}

float3 AtomInfo::coords() const
{
    if (_atom->lattice())
    {
        return std::move(_atom->lattice()->crystal()->translate(_atom->lattice()->coords()));
    }
    else
    {
        const Atom *crystAtom = _atom->firstCrystalNeighbour();
        assert(crystAtom->lattice());

        auto crystal = crystAtom->lattice()->crystal();
        auto crds = crystal->translate(crystAtom->lattice()->coords());
        crds.z += crystal->periods().z * 1.618;
        return std::move(crds);
    }
}

std::string AtomInfo::options() const
{
    int hc = _atom->hCount();
    assert(hc >= 0);

    if (hc == 0 || (_atom->lattice() && _atom->lattice()->coords().z == 0))
    {
        hc = -1;
    }

    std::stringstream ss;
    ss << "CHG=-" << _atom->actives() << " "
       << "HCOUNT=" << hc;

    return ss.str();
}

}
