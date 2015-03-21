#ifndef VOLUMESAVERSBUILDER_H
#define VOLUMESAVERSBUILDER_H

#include "savers_builder.h"
#include "volume_saver.h"

namespace vd {

class VolumeSaversBuilder : public SaversBuilder
{
    const Detector* _detector;
    double _currentTime;
    std::string _volumeSaverType;
    VolumeSaver* _saver;
public:
    VolumeSaversBuilder(const Detector* detector,
                        double currentTime,
                        std::string saverType,
                        double step) :
        SaversBuilder(step),
        _detector(detector),
        _currentTime(currentTime),
        _volumeSaverType(saverType) { _saver = takeSaver(_volumeSaverType); }

    void save(Amorph *amorph, Crystal *crystal);
    QueueItem wrapItem(QueueItem* item);
private:
    VolumeSaver* takeSaver(std::string volumeSaverType);
};

}

#endif // VOLUMESAVERSBUILDER_H
