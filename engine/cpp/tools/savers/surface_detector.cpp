#include "surface_detector.h"

namespace vd {

bool SurfaceDetector::isBottom(const Atom *atom)
{
    if (!atom->is(24)) return false;

    bool b = false;
    atom->eachNeighbour([&b](Atom *nbr) {
        if (!nbr->is(24))
        {
            b = true;
        }
    });

    return b;
}

}
