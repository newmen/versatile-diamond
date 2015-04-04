#ifndef INIT_CONFIG_H
#define INIT_CONFIG_H

#include <cstdlib>
#include "../phases/behavior_factory.h"
#include "../savers/detector_factory.h"
#include "../savers/dump_saver_builder.h"
#include "../savers/decorator/soul.h"
#include "../savers/integral_saver_builder.h"
#include "../savers/volume_savers_builder.h"
#include "../phases/behavior.h"
#include "yaml_config_reader.h"
#include "treker.h"
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

    InitConfig(int argc, char *argv[]);

    std::string filename() const;
};

///////////////////////////////////////////////////////////////////////////////////

template <class HB>
InitConfig<HB>::InitConfig(int argc, char *argv[]) : name(argv[1])
{
    for (int i = 1; i < argc; i++)
    {
        std::string allStr(argv[i]);
        if(allStr.find("--dump"))
        {
            loadFromDump = true;
            dumpPath = argv[i+1];
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
std::string InitConfig<HB>::filename() const
{
    std::stringstream ss;
    ss << name << "-" << x << "x" << y << "-" << totalTime << "s";
    return ss.str();
}

#endif // INIT_CONFIG_H
