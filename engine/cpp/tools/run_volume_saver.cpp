#include "run_volume_saver.h"
#include "savers/detector_factory.h"

namespace vd {

VolumeSaver *RunVolumeSaver::takeSaver(std::string volumeSaverType, std::string filename)
{
    VolumeSaverFactory vsFactory;
    return vsFactory.create(volumeSaverType, filename);
}

Detector *RunVolumeSaver::takeDetector(std::string detectorType)
{
    DetectorFactory<HB> detFactory;
    return detFactory.create(detectorType);
}

}
