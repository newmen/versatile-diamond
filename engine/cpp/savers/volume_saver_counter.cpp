#include "volume_saver_counter.h"
#include "volume_saver_factory.h"
#include "queue/queue_item.h"

namespace vd {

VolumeSaverCounter::VolumeSaverCounter(const Detector *detector, std::string saverType, const char *name, double step) :
    SaverCounter(step), _detector(detector)
{
    VolumeSaverFactory* vsFactory = new VolumeSaverFactory();
    _saver = vsFactory->create(saverType, name);
}

void VolumeSaverCounter::save(const SavingData &sd)
{
    _saver->save(sd.currentTime, sd.amorph, sd.crystal, _detector);
}

}
