#ifndef VOLUME_SAVER_H
#define VOLUME_SAVER_H

#include "../../atoms/atom.h"
#include "detector.h"
#include "accumulator.h"

namespace vd
{

class VolumeSaver
{
    std::string _name;

public:
    virtual ~VolumeSaver() {}
    virtual void writeFrom(Atom *atom, double currentTime, const Detector *detector) = 0;

    const std::string &name() const { return _name; }

protected:
    VolumeSaver(const char *name) : _name(name) {}

    virtual std::string filename() const = 0;
    virtual const char *ext() const = 0;

    void accumulateToFrom(Accumulator *acc, Atom *atom) const;
};

}

#endif // VOLUME_SAVER_H
