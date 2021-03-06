#include "all_atoms_detector.h"

namespace vd
{

bool AllAtomsDetector::isBottom(const SavingAtom *atom) const
{
    return atom->lattice() && atom->lattice()->coords().z == 0;
}

bool AllAtomsDetector::isShown(const SavingAtom *) const
{
    return true;
}

}
