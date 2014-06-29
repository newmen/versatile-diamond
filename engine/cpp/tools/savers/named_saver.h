#ifndef NAMED_SAVER_H
#define NAMED_SAVER_H

#include "../../atoms/atom.h"
#include "detector.h"

namespace vd {

class NamedSaver
{
    std::string _name;

public:
    NamedSaver(const char *name) : _name(name) {}
    virtual ~NamedSaver() {}

    const std::string &name() const { return _name; }

    virtual void writeFrom(Atom *atom, double currentTime, const Detector *detector) = 0;
};

}

#endif // NAMED_SAVER_H
