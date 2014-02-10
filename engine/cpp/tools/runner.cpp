#include "runner.h"
#include "savers/volume_saver_factory.h"

namespace vd
{

volatile bool Runner::__stopCalculating = false;

void Runner::stop()
{
    __stopCalculating = true;
}

Runner::Runner(const char *name, uint x, uint y, double totalTime, double eachTime, const char *volumeSaverType) :
    _name(name), _x(x), _y(y), _totalTime(totalTime), _eachTime(eachTime)
{
    if (_name.size() == 0)
    {
        throw Error("Name should not be empty");
    }
    else if (x == 0 || y == 0)
    {
        throw Error("X and Y sizes should be grater than 0");
    }
    else if (_totalTime <= 0)
    {
        throw Error("Total process time should be grater than 0 seconds");
    }
    else if (_eachTime <= 0)
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

        _volumeSaver = vsFactory.create(volumeSaverType, filename().c_str());
    }

    RandomGenerator::init(); // it must be called just one time at calculating begin (before init CommonMCData)
}

Runner::~Runner()
{
    delete _volumeSaver;
}

std::string Runner::filename() const
{
    std::stringstream ss;
    ss << _name << "_" << _x << "x" << _y << "_" << _totalTime << "s";
    return ss.str();
}

}
