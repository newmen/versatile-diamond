#ifndef INIT_CONFIG_H
#define INIT_CONFIG_H

#include <cstdlib>
#include "../phases/behavior_factory.h"
#include "../savers/detector_factory.h"
#include "../savers/dump_saver_counter.h"
#include "../savers/queue/soul.h"
#include "../savers/integral_saver_counter.h"
#include "../savers/volume_saver_counter.h"
#include "../savers/progress_saver_counter.h"
#include "../savers/volume_saver_factory.h"
#include "../savers/mol_saver.h"
#include "../savers/xyz_saver.h"
#include "../savers/sdf_saver.h"
#include "../savers/progress_saver.h"
#include "../phases/behavior.h"
#include "yaml_config_reader.h"
#include "traker.h"
#include "common.h"
#include "error.h"


using namespace vd;

template <class HB>
class InitConfig
{
    enum : ushort { MAX_HEIGHT = 100 };

    const YAMLConfigReader _yamlReader = *new YAMLConfigReader("configs/run.yml");

    const char *_name = nullptr;
    uint _x = 0, _y = 0;
    double _totalTime = 0;
    const Behavior *_behavior = nullptr;

    CrystalSliceSaver *_csSaver = nullptr;
    DumpSaver *_dmpSaver = nullptr;
    ProgressSaver<HB> *_prgrsSaver = nullptr;

    bool _loadFromDump = false;
    std::string _dumpPath;

    Traker _traker;

public:
    InitConfig(int argc, char *argv[]);
    ~InitConfig();

    void initTraker(const std::initializer_list<ushort> &types);
    typename HB::SurfaceCrystal *initCrystal() const;

    QueueItem *takeItem(const Amorph *amorph, const Crystal *crystal) const;

    void appendTime(double dt);

    const char *name() const { return _name; }
    double totalTime() const { return _totalTime; }

private:
    VolumeSaverCounter *createVSCounter(const char *from, const DetectorFactory<HB> &detFactory) const;

    double readStep(const char *from) const;
    std::string readDetector(const char *from) const;

    std::string filename() const;

    void checkExceptions() const;
    void checkWarnings() const;
};

///////////////////////////////////////////////////////////////////////////////////

template <class HB>
InitConfig<HB>::InitConfig(int argc, char *argv[]) : _name(argv[1])
{
    if (argc == 3)
    {
        std::string str(argv[2]);
        if(str == "--dump")
        {
            _loadFromDump = true;
            _dumpPath = argv[3];
        }
    }

    if (_yamlReader.isDefined("system", "size_x"))
    {
        _x = _yamlReader.read<uint>("system", "size_x");
    }

    if (_yamlReader.isDefined("system", "size_y"))
    {
        _y = _yamlReader.read<uint>("system", "size_y");
    }

    if (_yamlReader.isDefined("system", "time"))
    {
        _totalTime = _yamlReader.read<double>("system", "time");
    }

    if (_yamlReader.isDefined("system", "behavior"))
    {
        BehaviorFactory bhvrFactory;
        std::string bhvrType = _yamlReader.read<std::string>("system", "behavior");

        if (bhvrFactory.isRegistered(bhvrType))
        {
            _behavior = bhvrFactory.create(bhvrType);
        }
    }
}

template <class HB>
InitConfig<HB>::~InitConfig()
{
    if (_csSaver)
    {
        delete _csSaver;
    }
    if (_dmpSaver)
    {
        delete _dmpSaver;
    }
    if (_prgrsSaver)
    {
        delete _prgrsSaver;
    }
}

template <class HB>
void InitConfig<HB>::initTraker(const std::initializer_list<ushort> &types)
{
    checkExceptions();
    checkWarnings();

    if (_yamlReader.isDefined("integral"))
    {
        _csSaver = new CrystalSliceSaver(filename().c_str(), _x * _y, types);
        _traker.add(new IntegralSaverCounter(readStep("integral"), _csSaver));
    }

    DetectorFactory<HB> detFactory;
    if (_yamlReader.isDefined("dump"))
    {
        _dmpSaver = new DumpSaver(filename().c_str(), _x, _y);
        _traker.add(new DumpSaverCounter<HB>(readStep("dump"), _dmpSaver));
    }

    if (_yamlReader.isDefined("mol"))
    {
        _traker.add(createVSCounter("mol", detFactory));
    }

    if (_yamlReader.isDefined("sdf"))
    {
        _traker.add(createVSCounter("sdf", detFactory));
    }

    if (_yamlReader.isDefined("xyz"))
    {
        _traker.add(createVSCounter("xyz", detFactory));
    }

    if (_yamlReader.isDefined("progress"))
    {
        _prgrsSaver = new ProgressSaver<HB>();
        _traker.add(new ProgressSaverCounter<HB>(readStep("progress"), _prgrsSaver));
    }
}

template <class HB>
typename HB::SurfaceCrystal *InitConfig<HB>::initCrystal() const
{
    const BehaviorFactory bhvrFactory;
    const Behavior *initBhv = bhvrFactory.create("tor");
    typedef typename HB::SurfaceCrystal SC;
    SC *surfaceCrystal = new SC(dim3(_x, _y, MAX_HEIGHT), initBhv);
    surfaceCrystal->initialize();
    surfaceCrystal->changeBehavior(_behavior);
    return surfaceCrystal;
}

template <class HB>
QueueItem *InitConfig<HB>::takeItem(const Amorph *amorph, const Crystal *crystal) const
{
    return _traker.takeItem(new Soul(amorph, crystal));
}

template <class HB>
void InitConfig<HB>::appendTime(double dt)
{
    _traker.appendTime(dt);
}

template <class HB>
std::string InitConfig<HB>::filename() const
{
    std::stringstream ss;
    ss << _name << "-" << _x << "x" << _y << "-" << _totalTime << "s";
    return ss.str();
}

template <class HB>
void InitConfig<HB>::checkExceptions() const
{
    if (_x == 0 || _y == 0)
    {
        throw Error("Sizes are not determined.");
    }

    if (_totalTime == 0)
    {
        throw Error("Total time is not determined.");
    }
    else if (_totalTime <= 0)
    {
        throw Error("Total process time should be grater than 0 seconds");
    }

    if (!_name)
    {
        throw Error("Name should not be empty");
    }

    if (!_behavior)
    {
        throw Error("Undefined type of behavior");
    }
}

template <class HB>
void InitConfig<HB>::checkWarnings() const
{
    if ((_x == 0 || _y == 0) && _loadFromDump)
    {
        std::cout << std::endl << "WARNING! Sizes don`t need when load from dump." << std::endl;
    }
}

template <class HB>
double InitConfig<HB>::readStep(const char *from) const
{
    return _yamlReader.read<double>(from, "step");
}

template <class HB>
std::string InitConfig<HB>::readDetector(const char *from) const
{
    return _yamlReader.read<std::string>(from, "detector");
}

template <class HB>
VolumeSaverCounter *InitConfig<HB>::createVSCounter(const char *from, const DetectorFactory<HB> &detFactory) const
{
    VolumeSaverFactory vsFactory;
    return new VolumeSaverCounter(detFactory.create(readDetector(from)), vsFactory.create(from, filename().c_str()), readStep(from));
}

#endif // INIT_CONFIG_H
