#ifndef SURFACE_DETECTOR_H
#define SURFACE_DETECTOR_H

#include "../../atoms/atom.h"
#include "detector.h"

namespace vd {

template <ushort AT>
class SurfaceDetector : public Detector
{
public:
    SurfaceDetector() = default;
    bool isBottom(const Atom *atom) const;
};

//////////////////////////////////////////////////////////////////

template<ushort AT>
bool SurfaceDetector<AT>::isBottom(const Atom *atom) const
{
    if (!atom->is(AT)) return false;

    bool b = false;
    atom->eachNeighbour([&b](Atom *nbr) {
        if (!nbr->is(AT))
        {
            b = true;
        }
    });

    return b;
}

}

#endif // SURFACE_DETECTOR_H
