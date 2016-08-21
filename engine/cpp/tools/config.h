#ifndef CONFIG_H
#define CONFIG_H

#include <string>
#include <vector>
#include "../phases/behavior.h"
#include "../phases/behavior_factory.h"
#include "common.h"

namespace vd
{

class Config
{
public:
    typedef std::vector<ushort> AtomTypes;

private:
    enum : ushort { MAX_HEIGHT = 100 };

    const std::string _name;
    uint _sizeX, _sizeY;
    const Behavior *_behavior;
    double _totalTime;
    const AtomTypes _atomTypes;

public:
    Config(const std::string name,
           uint sizeX, uint sizeY,
           const Behavior *behavior,
           double totalTime,
           const AtomTypes &atomTypes) :
        _name(name),
        _sizeX(sizeX), _sizeY(sizeY),
        _behavior(behavior),
        _totalTime(totalTime),
        _atomTypes(atomTypes) {}

    const std::string &name() const { return _name; }
    uint sizeX() const { return _sizeX; }
    uint sizeY() const { return _sizeY; }
    uint sizeZ() const { return MAX_HEIGHT; }
    dim3 sizes() const { return dim3(sizeX(), sizeY(), sizeZ()); }
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
    const Behavior *initialBehavior = BehaviorFactory().create("tor");
    SurfaceCrystal *crystal = new SurfaceCrystal(sizes(), initialBehavior);
    crystal->initialize();
    crystal->changeBehavior(behavior());
    return crystal;
}

}

#endif //CONFIG_H
