#ifndef DETECTOR_H
#define DETECTOR_H

#include "../../atoms/saving_atom.h"

namespace vd {

class Detector
{
protected:
    Detector() = default;

public:
    virtual ~Detector() {}

    virtual bool isBottom(const SavingAtom *atom) const = 0;
    virtual bool isShown(const SavingAtom *atom) const = 0;
};

}

#endif // DETECTOR_H
