#ifndef VOLUME_SAVER_H
#define VOLUME_SAVER_H

#include "../../atoms/atom.h"
#include "detector.h"

namespace vd {

class VolumeSaver
{
    std::string _name;

public:
    VolumeSaver(const char *name) : _name(name) {}
    virtual ~VolumeSaver() {}

    const std::string &name() const { return _name; }

    virtual void writeFrom(Atom *atom, double currentTime, const Detector *detector) = 0;
};

}

#endif // VOLUME_SAVER_H
