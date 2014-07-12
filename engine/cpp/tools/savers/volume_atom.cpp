#include "volume_atom.h"

namespace vd
{

float3 VolumeAtom::coords() const
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
        crds.z += crystal->periods().z * 1.618; // because so near to bottom layer
        return crds;
    }
}

}
