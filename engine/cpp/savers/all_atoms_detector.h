#ifndef ALL_ATOMS_DETECTOR_H
#define ALL_ATOMS_DETECTOR_H

#include "../atoms/saving_atom.h"
#include "detector.h"

namespace vd {

class AllAtomsDetector : public Detector
{
public:
    AllAtomsDetector() {}

    bool isBottom(const SavingAtom *atom) const override;
    bool isShown(const SavingAtom *) const override;

private:
    AllAtomsDetector(const AllAtomsDetector &) = delete;
    AllAtomsDetector(AllAtomsDetector &&) = delete;
    AllAtomsDetector &operator = (const AllAtomsDetector &) = delete;
    AllAtomsDetector &operator = (AllAtomsDetector &&) = delete;
};

}

#endif // ALL_ATOMS_DETECTOR_H
