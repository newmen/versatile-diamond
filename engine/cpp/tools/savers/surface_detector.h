#ifndef SURFACE_DETECTOR_H
#define SURFACE_DETECTOR_H

#include "../../atoms/saving_atom.h"
#include "detector.h"

namespace vd {

template <class HB>
class SurfaceDetector : public Detector
{
public:
    SurfaceDetector() {}

    bool isBottom(const SavingAtom *atom) const override;
    bool isShown(const SavingAtom *atom) const override;

private:
    SurfaceDetector(const SurfaceDetector &) = delete;
    SurfaceDetector(SurfaceDetector &&) = delete;
    SurfaceDetector &operator = (const SurfaceDetector &) = delete;
    SurfaceDetector &operator = (SurfaceDetector &&) = delete;
};

//////////////////////////////////////////////////////////////////

template <class HB>
bool SurfaceDetector<HB>::isBottom(const SavingAtom *atom) const
{
    return HB::isRegular(atom->type());
}

template <class HB>
bool SurfaceDetector<HB>::isShown(const SavingAtom *atom) const
{
    if (!HB::isRegular(atom->type())) return true;

    SavingCrystal *crystal = atom->lattice()->crystal();
    bool b = true;
    atom->eachNeighbour([&b, crystal](SavingAtom *nbr) {
        b = b && HB::isRegular(nbr->type()) && crystal == nbr->lattice()->crystal();
    });

    return !b;
}

}

#endif // SURFACE_DETECTOR_H
