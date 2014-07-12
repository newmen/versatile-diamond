#ifndef XYZ_FORMAT_H
#define XYZ_FORMAT_H

#include <ostream>
#include "volume_saver.h"
#include "xyz_accumulator.h"

namespace vd
{

class XYZFormat
{
    const VolumeSaver &_saver;
    const XYZAccumulator &_acc;

public:
    XYZFormat(const VolumeSaver &saver, const XYZAccumulator &acc) : _saver(saver), _acc(acc) {}

    void render(std::ostream &os, double currentTime) const;

private:
    void writeHead(std::ostream &os, double currentTime) const;
    void writeAtoms(std::ostream &os) const;
};

}
#endif // XYZ_FORMAT_H
