#include "volume_savers_builder.h"
#include "volume_saver_factory.h"
#include "decorator/volume_saver_item.h"

namespace vd {

void VolumeSaversBuilder::save(Amorph *amorph, Crystal *crystal)
{
    takeSaver(_volumeSaverType)->save(_currentTime, amorph, crystal, _detector);
}

QueueItem VolumeSaversBuilder::wrapItem(QueueItem* item)
{
    return new VolumeSaverItem(_item, *this);
}

VolumeSaver *VolumeSaversBuilder::takeSaver(std::string volumeSaverType)
{
    VolumeSaverFactory* vsFactory;
    return vsFactory->create(volumeSaverType);
}

}
