#include "volume_saver_counter.h"

namespace vd {

VolumeSaverCounter::VolumeSaverCounter(const Detector *detector, VolumeSaver *saver, double step) :
    CounterWhithSaver(step, saver), _detector(detector)
{
}

VolumeSaverCounter::~VolumeSaverCounter()
{
    delete _detector;
}

void VolumeSaverCounter::save(const SavingData &sd)
{
    saver()->save(sd.currentTime, sd.amorph, sd.crystal, _detector);
}

}
