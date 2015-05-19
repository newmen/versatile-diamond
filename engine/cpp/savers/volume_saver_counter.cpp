#include "volume_saver_counter.h"
#include "volume_saver_factory.h"
#include "decorator/queue_item.h"

namespace vd {

VolumeSaverCounter::VolumeSaverCounter(const Detector *detector, std::string saverType, const char *name, double step) :
    SaverCounter(step),
    _detector(detector),
    _volumeSaverType(saverType)
{
    _saver = takeSaver(_volumeSaverType, name);
}

void VolumeSaverCounter::save(const SavingData &sd)
{
    takeSaver(_volumeSaverType, sd.name)->save(sd.currentTime, sd.amorph, sd.crystal, _detector);
}

VolumeSaver *VolumeSaverCounter::takeSaver(std::string volumeSaverType, const char *name)
{
    VolumeSaverFactory* vsFactory = new VolumeSaverFactory();
    return vsFactory->create(volumeSaverType, name);
}

}
