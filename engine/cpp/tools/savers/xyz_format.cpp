#include "xyz_format.h"

namespace vd
{

void XYZFormat::render(std::ostream &os, double currentTime) const
{
    writeHead(os, currentTime);
    writeAtoms(os);
}

void XYZFormat::writeHead(std::ostream &os, double currentTime) const
{
    os << acc().atoms().size() << "\n"
         << "Name: "
         << saver().name()
         << " Current time: "
         << currentTime << "s" << "\n";
}

void XYZFormat::writeAtoms(std::ostream &os) const
{
    for (const Atom *atom : acc().atoms())
    {
        const float3 &crd = atom->realPosition();
        os << atom->name() << " "
           << crd.x << " "
           << crd.y << " "
           << crd.z << "\n";
    }
}

}
