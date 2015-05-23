#ifndef VOLUME_SAVER_H
#define VOLUME_SAVER_H

#include "../phases/saving_amorph.h"
#include "../phases/saving_crystal.h"
#include "detector.h"

namespace vd
{

class VolumeSaver
{
    std::string _name;
    uint _x, _y;

public:
    virtual ~VolumeSaver() {}
    virtual void save(double currentTime, const SavingAmorph *amorph, const SavingCrystal *crystal, const Detector *detector) = 0;

    const std::string &name() const { return _name; }
    uint x() const { return _x; }
    uint y() const { return _y; }

protected:
    VolumeSaver(const char *name, uint x, uint y) : _name(name), _x(x), _y(y) {}
    VolumeSaver(const char *name) : _name(name) {}

    virtual std::string filename() const = 0;
    virtual const char *ext() const = 0;
};

}

#endif // VOLUME_SAVER_H
