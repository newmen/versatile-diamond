#include "volume_saver_item.h"
#include "savers/detector_factory.h"

namespace vd {

VolumeSaver *VolumeSaverItem::takeSaver(std::string volumeSaverType, std::string filename)
{
    VolumeSaverFactory vsFactory;
    return vsFactory.create(volumeSaverType, filename);
}

Detector *VolumeSaverItem::takeDetector(std::string detectorType)
{
    DetectorFactory<HB> detFactory;
    return detFactory.create(detectorType);
}

}

