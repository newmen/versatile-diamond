#include "runner.h"
#include <sys/time.h>
#include "savers/volume_saver_factory.h"
#include "process_mem_usage.h"

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

double Runner::timestamp() const
{
    timeval tv;
    gettimeofday(&tv, 0);
    return tv.tv_sec + tv.tv_usec / 1e6;
}

void Runner::outputMemoryUsage(std::ostream &os) const
{
    double vm, rss;
    process_mem_usage(vm, rss);
    os.precision(5);
    os << "Used virtual memory: " << (vm / 1024) << " MB\n"
       << "Used resident set: " << (rss / 1024) << " MB" << std::endl;
}

}
