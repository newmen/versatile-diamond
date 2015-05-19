#ifndef INIT_CONFIG_H
#define INIT_CONFIG_H

#include <cstdlib>
#include "../phases/behavior_factory.h"
#include "../savers/detector_factory.h"
#include "../savers/dump_saver_counter.h"
#include "../savers/decorator/soul.h"
#include "../savers/integral_saver_counter.h"
#include "../savers/volume_saver_counter.h"
#include "../savers/progress_saver_counter.h"
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
    Behavior *behavior;
    YAMLConfigReader *yamlReader;
    Traker *traker = new Traker();

    InitConfig(int argc, char *argv[]);

    void initTraker(const std::initializer_list<ushort> &types) const;
    std::string filename() const;
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
    if (yamlReader->isDefined("system", "size_x") && yamlReader->isDefined("system", "size_y"))
    {
        x = yamlReader->read<uint>("system", "size_x");
        y = yamlReader->read<uint>("system", "size_y");
    }
    else
        throw Error("Sizes are not determined.");

    if (yamlReader->isDefined("system", "time"))
        totalTime = yamlReader->read<double>("system", "time");
    else
        throw Error("Total time is not determined.");

    if (name.size() == 0)
    {
        throw Error("Name should not be empty");
    }
    else if (x == 0 || y == 0)
    {
        throw Error("X and Y sizes should be grater than 0");
    }
    else if (totalTime <= 0)
    {
        throw Error("Total process time should be grater than 0 seconds");
    }

    if (yamlReader->isDefined("system", "behavior"))
    {
        BehaviorFactory bhvrFactory;
        std::string bhvrType = yamlReader->read<std::string>("system", "behavior");

        if (!bhvrFactory.isRegistered(bhvrType))
        {
            throw Error("Undefined type of behavior");
        }

        behavior = bhvrFactory.create(bhvrType);
    }
}

template <class HB>
void InitConfig<HB>::initTraker(const std::initializer_list<ushort> &types) const
{
    DetectorFactory<HB> detFactory;

    if (yamlReader->isDefined("integral", "step"))
    {
        traker->addItem(new IntegralSaverCounter(
                            name.c_str(),
                            x * y,
                            types,
                            yamlReader->read<double>("integral", "step")));
    }

    if (yamlReader->isDefined("dump", "step"))
    {
        traker->addItem(new DumpSaverCounter(
                            x,
                            y,
                            detFactory.create("all"),
                            yamlReader->read<double>("dump", "step")));
    }

    if (yamlReader->isDefined("mol", "step"))
    {
        traker->addItem(new VolumeSaverCounter(
                            detFactory.create(yamlReader->read<std::string>("mol", "detector")),
                            "mol",
                            name.c_str(),
                            yamlReader->read<double>("mol", "step")));
    }

    if (yamlReader->isDefined("sdf", "step"))
    {
        traker->addItem(new VolumeSaverCounter(
                            detFactory.create(yamlReader->read<std::string>("sdf", "detector")),
                            "sdf",
                            name.c_str(),
                            yamlReader->read<double>("sdf", "step")));
    }

    if (yamlReader->isDefined("xyz", "step"))
    {
        traker->addItem(new VolumeSaverCounter(
                            detFactory.create(yamlReader->read<std::string>("xyz", "detector")),
                            "xyz",
                            name.c_str(),
                            yamlReader->read<double>("xyz", "step")));
    }

    if (yamlReader->isDefined("progress", "step"))
    {
        traker->addItem(new ProgressSaverCounter<HB>(yamlReader->read<double>("progress", "step")));
    }
}


template <class HB>
std::string InitConfig<HB>::filename() const
{
    std::stringstream ss;
    ss << name << "-" << x << "x" << y << "-" << totalTime << "s";
    return ss.str();
}

#endif // INIT_CONFIG_H
