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

    bool isBottom(const Atom *atom) const override;
    bool isShown(const Atom *atom) const override;
};

//////////////////////////////////////////////////////////////////

template<ushort AT>
bool SurfaceDetector<AT>::isBottom(const Atom *atom) const
{
    return atom->is(AT);
}

template<ushort AT>
bool SurfaceDetector<AT>::isShown(const Atom *atom) const
{
    if (!atom->is(AT)) return true;

    bool b = true;
    atom->eachNeighbour([&b](Atom *nbr) {
        b &= nbr->is(AT);
    });

    return !b;
}

}

#endif // SURFACE_DETECTOR_H