#ifndef VOLUMESAVERITEM_H
#define VOLUMESAVERITEM_H

#include "item_wrapper.h"
#include "savers/volume_saver_factory.h"
#include "savers/detector.h"

namespace vd {

class VolumeSaverItem : public ItemWrapper
{
public:
    VolumeSaverItem(SaversDecorator* targ) : ItemWrapper(targ) {}

private:
    VolumeSaver* takeSaver(std::string volumeSaverType, std::string filename);
    Detector* takeDetector(std::string detectorType);
};

}

#endif // VOLUMESAVERITEM_H
