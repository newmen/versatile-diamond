#ifndef SURFACE_DETECTOR_H
#define SURFACE_DETECTOR_H

#include "../atoms/atom.h"
#include "detector.h"

namespace vd {

template <class HB>
class SurfaceDetector : public Detector
{
public:
    SurfaceDetector() {}

    bool isBottom(const Atom *atom) const override;
    bool isShown(const Atom *atom) const override;

private:
    SurfaceDetector(const SurfaceDetector &) = delete;
    SurfaceDetector(SurfaceDetector &&) = delete;
    SurfaceDetector &operator = (const SurfaceDetector &) = delete;
    SurfaceDetector &operator = (SurfaceDetector &&) = delete;
};

//////////////////////////////////////////////////////////////////

template <class HB>
bool SurfaceDetector<HB>::isBottom(const Atom *atom) const
{
    return HB::isRegular(atom);
}

template <class HB>
bool SurfaceDetector<HB>::isShown(const Atom *atom) const
{
    if (!HB::isRegular(atom)) return true;

    Crystal *crystal = atom->lattice()->crystal();
    bool b = true;
    atom->eachNeighbour([&b, crystal](Atom *nbr) {
        b = b && HB::isRegular(nbr) && crystal == nbr->lattice()->crystal();
    });

    return !b;
}

}

#endif // SURFACE_DETECTOR_H
