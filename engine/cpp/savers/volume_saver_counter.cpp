#include "volume_saver_counter.h"

namespace vd {

VolumeSaverCounter::VolumeSaverCounter(const Detector *detector, VolumeSaver *saver, double step) :
    SaverCounter(step), _detector(detector), _saver(saver)
{
}

VolumeSaverCounter::~VolumeSaverCounter()
{
    delete _saver;
    delete _detector;
}

void VolumeSaverCounter::save(const SavingData &sd)
{
    _saver->save(sd.currentTime, sd.amorph, sd.crystal, _detector);
}

}
