#include "atom_info.h"
#include <sstream>

namespace vd
{

AtomInfo::AtomInfo(const Atom *atom) : _atom(atom)
{
}

bool AtomInfo::operator == (const AtomInfo &other) const
{
    return _atom == other._atom;
}

void AtomInfo::incNoBond()
{
    ++_noBond;
}

const char *AtomInfo::type() const
{
    return _atom->name();
}

float3 AtomInfo::coords() const
{
    if (_atom->lattice())
    {
        return _atom->lattice()->crystal()->translate(_atom->lattice()->coords());
    }
    else
    {
        const Atom *crystAtom = _atom->firstCrystalNeighbour();
        assert(crystAtom->lattice());

        auto crystal = crystAtom->lattice()->crystal();
        auto crds = crystal->translate(crystAtom->lattice()->coords());
        crds.z += crystal->periods().z * 1.618;
        return crds;
    }
}

}
