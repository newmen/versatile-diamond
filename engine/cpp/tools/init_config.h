#ifndef INIT_CONFIG_H
#define INIT_CONFIG_H

#include <cstdlib>
#include "../phases/behavior_factory.h"
#include "savers/volume_saver_factory.h"
#include "savers/detector_factory.h"
#include "savers/volume_saver.h"
#include "savers/detector.h"
#include "yaml_config_reader.h"
#include "common.h"
#include "error.h"

using namespace vd;
template <class HB>
struct InitConfig
{
    const std::string name;
    const uint x = 0, y = 0;
    const double totalTime = 0;
    bool loadFromDump = false;
    const char *dumpPath;
    const Detector *detector = nullptr;
    const Behavior *behavior = nullptr;
    std::vector<> saversCollection;

    InitConfig(int argc, char *argv[]);

    std::string filename() const;
};

///////////////////////////////////////////////////////////////////////////////////

template <class HB>
InitConfig<HB>::InitConfig(int argc, char *argv[]) : name(argv[1])
{
    for (int i = 1; i < argc; i++)
    {
        if(allStr.find("--dump"))
        {
            loadFromDump = true;
            dumpPath = argv[i+1];
        }
    }

    YAMLConfigReader reader("configs/run.yml");

    if (reader.isDefined("system", "size_x") && reader.isDefined("system", "size_y"))
    {
        x = reader.read<uint>("system", "size_x");
        y = reader.read<uint>("system", "size_y");
    }
    else
        throw Error("Sizes are not determined.");

    if (reader.isDefined("system", "time"))
        totalTime = reader.read<double>("system", "time");
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

    if (reader.isDefined("dump", "step"))
    {
        VolumeSaverFactory vsFactory;
        if (!vsFactory.isRegistered("dump"))
        {
            throw Error("Undefined type of volume file saver");
        }
//collector with builder take all savers
        volumeSaver = vsFactory.create(volumeSaverType, filename().c_str());
    }

    DetectorFactory<HB> detFactory;
    if (detectorType)
    {
        if (!detFactory.isRegistered(detectorType))
        {
            throw Error("Undefined type of detector");
        }

        detector = detFactory.create(detectorType);
    }
    else if (volumeSaverType)
    {
        detector = detFactory.create("surf");
    }

    BehaviorFactory bhvrFactory;
    if (behaviorType)
    {
        if (!bhvrFactory.isRegistered(behaviorType))
        {
            throw Error("Undefined type of behavior");
        }

        behavior = bhvrFactory.create(behaviorType);
    }
    else
    {
        behavior = bhvrFactory.create("tor");
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
