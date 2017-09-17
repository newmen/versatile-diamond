#ifndef CONFIG_H
#define CONFIG_H

#include <string>
#include <vector>
#include "../phases/behavior.h"
#include "common.h"

namespace vd
{

class Config
{
public:
    enum : ushort { MAX_HEIGHT = 100 };

    typedef std::vector<ushort> AtomTypes;

private:
    const std::string _name;
    uint _sizeX, _sizeY, _sizeZ;
    const Behavior *_behavior;
    double _totalTime;
    const AtomTypes _atomTypes;

public:
    Config(const std::string name,
           uint sizeX, uint sizeY, uint sizeZ,
           const Behavior *behavior,
           double totalTime,
           const AtomTypes &atomTypes) :
        _name(name),
        _sizeX(sizeX), _sizeY(sizeY), _sizeZ(sizeZ),
        _behavior(behavior),
        _totalTime(totalTime),
        _atomTypes(atomTypes) {}

    const std::string &name() const { return _name; }
    uint sizeX() const { return _sizeX; }
    uint sizeY() const { return _sizeY; }
    uint sizeZ() const { return _sizeZ; }
    dim3 sizes() const { return dim3(sizeX(), sizeY(), MAX_HEIGHT); }
    uint squire() const { return sizeX() * sizeY(); }
    const Behavior *behavior() const { return _behavior; }
    double totalTime() const { return _totalTime; }
    const AtomTypes &atomTypes() const { return _atomTypes; }

    std::string filename() const;

    template <class SurfaceCrystal>
    SurfaceCrystal *getCrystal() const; // allocates memory!
};

template <class SurfaceCrystal>
SurfaceCrystal *Config::getCrystal() const
{
    SurfaceCrystal *crystal = new SurfaceCrystal(sizes(), behavior(), sizeZ());
    crystal->initialize();
    return crystal;
}

}

#endif //CONFIG_H
