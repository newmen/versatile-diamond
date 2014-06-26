#ifndef ALL_ATOMS_DETECTOR_H
#define ALL_ATOMS_DETECTOR_H

#include "../../atoms/atom.h"

namespace vd {

class AllAtomsDetector
{
public:
    static bool isBottom(const Atom *);

protected:
    AllAtomsDetector() = default;
};

}
#endif // ALL_ATOMS_DETECTOR_H
