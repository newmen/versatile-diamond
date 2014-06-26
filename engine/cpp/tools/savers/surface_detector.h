#ifndef SURFACE_DETECTOR_H
#define SURFACE_DETECTOR_H

#include "../../atoms/atom.h"

namespace vd {

class SurfaceDetector
{
public:
    static bool isBottom(const Atom* atom);

protected:
    SurfaceDetector() = default;
};

}

#endif // SURFACE_DETECTOR_H
