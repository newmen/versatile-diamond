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

public:
    virtual ~VolumeSaver() {}
    virtual void save(double currentTime, const SavingAmorph *amorph, const SavingCrystal *crystal, const Detector *detector) = 0;

    const std::string &name() const { return _name; }

protected:
    VolumeSaver(const char *name) : _name(name) {}

    virtual std::string filename() const = 0;
    virtual const char *ext() const = 0;
};

}

#endif // VOLUME_SAVER_H
