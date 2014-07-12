#ifndef XYZ_FORMAT_H
#define XYZ_FORMAT_H

#include <ostream>
#include "format.h"
#include "xyz_accumulator.h"

namespace vd
{

class XYZFormat : public Format<XYZAccumulator>
{
public:
    XYZFormat(const VolumeSaver &saver, const XYZAccumulator &acc) : Format(saver, acc) {}

    void render(std::ostream &os, double currentTime) const;

private:
    void writeHead(std::ostream &os, double currentTime) const;
    void writeAtoms(std::ostream &os) const;
};

}

#endif // XYZ_FORMAT_H
