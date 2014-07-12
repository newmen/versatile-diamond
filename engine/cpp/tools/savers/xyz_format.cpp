#include "xyz_format.h"
#include "volume_atom.h"

namespace vd
{

void XYZFormat::render(std::ostream &os, double currentTime) const
{
    writeHead(os, currentTime);
    writeAtoms(os);
}

void XYZFormat::writeHead(std::ostream &os, double currentTime) const
{
    os << _acc.atomsNum() << "\n"
         << "Name: "
         << _saver.name()
         << " Current time: "
         << currentTime << "s" << "\n";
}

void XYZFormat::writeAtoms(std::ostream &os) const
{
    for (auto &pr : _acc.atoms())
    {
        const VolumeAtom &atom = pr.second;
        auto const &crd = atom.coords();
        os << atom.atom()->name() << " "
           << crd.x << " "
           << crd.y << " "
           << crd.z << "\n";
    }
}

}
