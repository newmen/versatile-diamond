#include "volume_savers_builder.h"
#include "volume_saver_factory.h"
#include "decorator/queue_item.h"

namespace vd {

VolumeSaversBuilder::VolumeSaversBuilder(const Detector *detector, std::string saverType, const char *name, double step) :
    SaverBuilder(step),
    _detector(detector),
    _volumeSaverType(saverType)
{
    _saver = takeSaver(_volumeSaverType, name);
}

void VolumeSaversBuilder::save(const SavingAmorph *amorph, const SavingCrystal *crystal, const char *name, double currentTime)
{
    takeSaver(_volumeSaverType, name)->save(currentTime, amorph, crystal, _detector);
}

VolumeSaver *VolumeSaversBuilder::takeSaver(std::string volumeSaverType, const char *name)
{
    VolumeSaverFactory* vsFactory;
    return vsFactory->create(volumeSaverType, name);
}

}
