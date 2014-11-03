#ifndef DETECTOR_H
#define DETECTOR_H

#include "../../atoms/atom.h"

namespace vd {

class Detector
{
protected:
    Detector() = default;

public:
    virtual ~Detector() {}

    virtual bool isBottom(const Atom *atom) const = 0;
    virtual bool isShown(const Atom *atom) const = 0;
};

}

#endif // DETECTOR_H
