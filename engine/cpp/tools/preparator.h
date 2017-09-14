#ifndef PREPARATOR_H
#define PREPARATOR_H

#include <string>
#include <memory>
#include "../phases/reactor.h"
#include "../phases/behavior_factory.h"
#include "../savers/detector_factory.h"
#include "../savers/progress_saver.h"
#include "../savers/slices_saver.h"
#include "../savers/xyz_saver.h"
#include "../savers/mol_saver.h"
#include "../savers/sdf_saver.h"
#include "yaml_config_reader.h"
#include "common.h"
#include "config.h"
#include "tracker.h"
#include "runner.h"
#include "error.h"

namespace vd {

template<class HB>
class Preparator {
    enum : ushort { MAX_CRYSTAL_HEIGHT = 100 };

    const YAMLConfigReader _yamlReader;
    const DetectorFactory<HB> _detectorFactory;

    std::string _runName;

    Config *_config = nullptr;
    Reactor<HB> *_reactor = nullptr;
    Tracker<HB> *_tracker = nullptr;
    Runner<HB> *_runner = nullptr;

public:
    Preparator(const char *runName);
    ~Preparator();

    Runner<HB> *runner();

private:
    Preparator(const Preparator &) = delete;
    Preparator(Preparator &&) = delete;
    Preparator &operator = (const Preparator &) = delete;
    Preparator &operator = (Preparator &&) = delete;

    const Config *config();
    Reactor<HB> *reactor();
    Tracker<HB> *tracker();

    template <class Saver> void trackSimpleSaver(const char *name);
    template <class Saver> void trackVolumeSaver(const char *name);

    double readStep(const char *key);
    std::string readDetector(const char *key);
};

///////////////////////////////////////////////////////////////////////////////////

template<class HB>
Preparator<HB>::Preparator(const char *runName) :
    _yamlReader(HB::runConfigPath()), _runName(runName)
{
}

template<class HB>
Preparator<HB>::~Preparator()
{
    delete _runner;
    delete _tracker;
    delete _reactor;
    delete _config;
}

template<class HB>
Runner<HB> *Preparator<HB>::runner()
{
    if (!_runner)
    {
        _runner = new Runner<HB>(config(), reactor(), tracker());
    }

    return _runner;
}

template<class HB>
const Config *Preparator<HB>::config()
{
    if (!_config)
    {
        if (_runName.empty())
        {
            throw Error("Run name has not passed as run argument");
        }

        uint sizeX = 0;
        if (_yamlReader.isDefined("system", "size_x"))
        {
            sizeX = _yamlReader.read<uint>("system", "size_x");
        }
        else
        {
            throw Error("system.size_x is not defined");
        }

        uint sizeY = 0;
        if (_yamlReader.isDefined("system", "size_y"))
        {
            sizeY = _yamlReader.read<uint>("system", "size_y");
        }
        else
        {
            throw Error("system.size_y is not defined");
        }

        uint sizeZ = 0;
        if (_yamlReader.isDefined("system", "size_z"))
        {
            sizeZ = _yamlReader.read<uint>("system", "size_z");
        }
        else
        {
            throw Error("system.size_z is not defined");
        }

        if (sizeX <= 0 || sizeY <= 0 || sizeZ <= 0)
        {
            throw Error("Wrong size value");
        }


        double totalTime = 0;
        if (_yamlReader.isDefined("system", "time"))
        {
            totalTime = _yamlReader.read<double>("system", "time");
        }
        else
        {
            throw Error("system.time is not defined");
        }
        if (totalTime <= 0)
        {
            throw Error("Total process time should be grater than 0 seconds");
        }

        const Behavior *behavior = nullptr;
        if (_yamlReader.isDefined("system", "behavior"))
        {
            BehaviorFactory behaviorFactory;
            std::string behaviorType = _yamlReader.read<std::string>("system", "behavior");

            if (behaviorFactory.isRegistered(behaviorType))
            {
                behavior = behaviorFactory.create(behaviorType);
            }
            else
            {
                throw Error("Undefined value for system.behavior (tor|plane)");
            }
        }
        else
        {
            throw Error("system.behavior is not defined");
        }

        Config::AtomTypes atomTypes;
        if (_yamlReader.isDefined("integral", "atom_types"))
        {
            atomTypes = _yamlReader.read<Config::AtomTypes>("integral", "atom_types");
        }

        _config = new Config(_runName, sizeX, sizeY, sizeZ, behavior, totalTime, atomTypes);
    }

    return _config;
}

template<class HB>
Reactor<HB> *Preparator<HB>::reactor()
{
    if (!_reactor)
    {
        _reactor = new Reactor<HB>(config());
    }

    return _reactor;
}

template<class HB>
Tracker<HB> *Preparator<HB>::tracker()
{
    if (!_tracker)
    {
        _tracker = new Tracker<HB>();

        if (_yamlReader.isDefined("progress"))
        {
            trackSimpleSaver<ProgressSaver<HB>>("progress");
        }

        if (_yamlReader.isDefined("integral"))
        {
            trackSimpleSaver<SlicesSaver<HB>>("integral");
        }

        if (_yamlReader.isDefined("xyz"))
        {
            trackVolumeSaver<XYZSaver>("xyz");
        }

        if (_yamlReader.isDefined("mol"))
        {
            trackVolumeSaver<MolSaver>("mol");
        }

        if (_yamlReader.isDefined("sdf"))
        {
            trackVolumeSaver<SdfSaver>("sdf");
        }
    }

    return _tracker;
}

template<class HB>
template <class Saver>
void Preparator<HB>::trackSimpleSaver(const char *name)
{
    assert(_tracker);
    _tracker->template add<Saver>(readStep(name), config());
}

template<class HB>
template <class Saver>
void Preparator<HB>::trackVolumeSaver(const char *name)
{
    assert(_tracker);
    const Detector *detector = _detectorFactory.create(readDetector(name));
    _tracker->template add<Saver>(readStep(name), config(), detector);
}

template<class HB>
double Preparator<HB>::readStep(const char *key) {
    return _yamlReader.read<double>(key, "step");
}

template<class HB>
std::string Preparator<HB>::readDetector(const char *key) {
    return _yamlReader.read<std::string>(key, "detector");
}

}


#endif //PREPARATOR_H
