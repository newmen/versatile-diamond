#ifndef VOLUMESAVERSBUILDER_H
#define VOLUMESAVERSBUILDER_H

#include "saver_builder.h"
#include "volume_saver.h"

namespace vd {

class VolumeSaversBuilder : public SaverBuilder
{
    const Detector* _detector;
    std::string _volumeSaverType;
    VolumeSaver* _saver;
public:
    VolumeSaversBuilder(const Detector* detector, std::string saverType, const char *name, double step);

    void save(const SavingData &sd) override;
private:
    VolumeSaver* takeSaver(std::string volumeSaverType, const char *name);
};

}

#endif // VOLUMESAVERSBUILDER_H
