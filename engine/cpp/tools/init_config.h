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
#include "../phases/behavior.h"
#include "yaml_config_reader.h"
#include "traker.h"
#include "common.h"
#include "error.h"

using namespace vd;

template <class HB>
struct InitConfig
{
    std::string name;
    uint x = 0, y = 0;
    double totalTime = 0;
    bool loadFromDump = false;
    const char *dumpPath;
    const Behavior *behavior;
    const YAMLConfigReader *yamlReader;
    Traker *traker = new Traker();

    InitConfig(int argc, char *argv[]);

    void initTraker(const std::initializer_list<ushort> &types) const;
    std::string filename() const;

private:
    double readStep(const char *from) const;
    std::string readDetector(const char *from) const;
};

///////////////////////////////////////////////////////////////////////////////////

template <class HB>
InitConfig<HB>::InitConfig(int argc, char *argv[]) : name(argv[1])
{
    if (argc == 3)
    {
        std::string str(argv[2]);
        if(str == "--dump")
        {
            loadFromDump = true;
            dumpPath = argv[3];
        }
    }

    yamlReader = new YAMLConfigReader("configs/run.yml");

    if (yamlReader->isDefined("system", "size_x") && yamlReader->isDefined("system", "size_y") && !loadFromDump)
    {
        x = yamlReader->read<uint>("system", "size_x");
        y = yamlReader->read<uint>("system", "size_y");
    }

    if (yamlReader->isDefined("system", "time"))
        totalTime = yamlReader->read<double>("system", "time");

    if (yamlReader->isDefined("system", "behavior"))
    {
        BehaviorFactory bhvrFactory;
        std::string bhvrType = yamlReader->read<std::string>("system", "behavior");

        if (bhvrFactory.isRegistered(bhvrType))
        {
            behavior = bhvrFactory.create(bhvrType);
        }
    }
}

template <class HB>
void InitConfig<HB>::initTraker(const std::initializer_list<ushort> &types) const
{

    if ((x == 0 || y == 0) && !loadFromDump)
    {
        throw Error("Sizes are not determined.");
    }

    if (totalTime == 0)
    {
        throw Error("Total time is not determined.");
    }
    else if (totalTime <= 0)
    {
        throw Error("Total process time should be grater than 0 seconds");
    }

    if (name.size() == 0)
    {
        throw Error("Name should not be empty");
    }

//    Проверка на существование поведения.
//    throw Error("Undefined type of behavior");

    if (yamlReader->isDefined("integral"))
    {
        traker->add(new IntegralSaverCounter(
                            filename().c_str(),
                            x * y,
                            types,
                            readStep("integral")));
    }

    DetectorFactory<HB> detFactory;
    if (yamlReader->isDefined("dump"))
    {
        traker->add(new DumpSaverCounter(
                            x,
                            y,
                            filename().c_str(),
                            detFactory.create("all"),
                            readStep("dump")));
    }

    VolumeSaverFactory vsFactory;
    if (yamlReader->isDefined("mol"))
    {
        traker->add(new VolumeSaverCounter(
                            detFactory.create(readDetector("mol")),
                            vsFactory.create("mol", filename().c_str()),
                            readStep("mol")));
    }

    if (yamlReader->isDefined("sdf"))
    {
        traker->add(new VolumeSaverCounter(
                            detFactory.create(readDetector("sdf")),
                            vsFactory.create("sdf", filename().c_str()),
                            readStep("sdf")));
    }

    if (yamlReader->isDefined("xyz"))
    {
        traker->add(new VolumeSaverCounter(
                            detFactory.create(readDetector("xyz")),
                            vsFactory.create("xyz", filename().c_str()),
                            readStep("xyz")));
    }

    if (yamlReader->isDefined("progress"))
    {
        traker->add(new ProgressSaverCounter<HB>(readStep("progress")));
    }
}

template <class HB>
std::string InitConfig<HB>::filename() const
{
    std::stringstream ss;
    ss << name << "-" << x << "x" << y << "-" << totalTime << "s";
    return ss.str();
}

template <class HB>
double InitConfig<HB>::readStep(const char *from) const
{
    return yamlReader->read<double>(from, "step");
}

template <class HB>
std::string InitConfig<HB>::readDetector(const char *from) const
{
    return yamlReader->read<std::string>(from, "detector");
}

#endif // INIT_CONFIG_H
