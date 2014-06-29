#include "all_atoms_detector.h"

namespace vd {

bool AllAtomsDetector::isBottom(const Atom *atom) const
{
    return atom->lattice() && atom->lattice()->coords().z == 0;
}

}
