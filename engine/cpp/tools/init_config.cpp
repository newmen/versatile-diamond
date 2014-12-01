#include "init_config.h"
#include "savers/volume_saver_factory.h"
#include "savers/detector_factory.h"
#include "../phases/behavior_factory.h"

InitConfig::InitConfig(int argc, char *argv[]) : name(argv[1]), x(atoi(argv[2])), y(atoi(argv[3])), totalTime(atof(argv[4])), eachTime(atof(argv[5]))
{
    const char *volumeSaverType;
    const char *detectorType;
    const char *behaviorType;

    volumeSaverType = (argc >= 7) ? argv[6] : nullptr;
    detectorType = (argc == 8) ? argv[7] : nullptr;
    behaviorType = (argc == 9) ? argv[8] : nullptr;

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
    else if (eachTime <= 0)
    {
        throw Error("Each time value should be grater than 0 seconds");
    }

    if (volumeSaverType)
    {
        VolumeSaverFactory vsFactory;
        if (!vsFactory.isRegistered(volumeSaverType))
        {
            throw Error("Undefined type of volume file saver");
        }

        volumeSaver = vsFactory.create(volumeSaverType, filename().c_str());
    }

    DetectorFactory<Handbook> detFactory;
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

InitConfig::~InitConfig()
{
    delete volumeSaver;
    delete detector;
}

std::string InitConfig::filename() const
{
    std::stringstream ss;
    ss << name << "-" << x << "x" << y << "-" << totalTime << "s";
    return ss.str();
}
