#ifndef RUNVOLUMESAVER_H
#define RUNVOLUMESAVER_H

#include "savers_wrapper.h"
#include "savers/volume_saver_factory.h"
#include "savers/detector.h"

namespace vd {

class RunVolumeSaver : public SaversWrapper
{
public:
    RunVolumeSaver(SaversDecorator* targ) : SaversWrapper(targ) {}

private:
    VolumeSaver* takeSaver(std::string volumeSaverType, std::string filename);
    Detector* takeDetector(std::string detectorType);
};

}

#endif // RUNVOLUMESAVER_H
