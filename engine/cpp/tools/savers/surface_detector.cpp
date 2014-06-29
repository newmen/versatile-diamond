#include "surface_detector.h"

namespace vd {

bool SurfaceDetector::isBottom(const Atom *atom)
{
    if (!atom->is(24)) return false;

    bool b = true;
    atom->eachNeighbour([&b](Atom *nbr) {
        if (!nbr->is(24))
        {
            b = false;
        }
    });

    return b;
}

}
