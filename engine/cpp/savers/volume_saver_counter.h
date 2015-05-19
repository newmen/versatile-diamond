#ifndef VOLUMESAVERCOUNTER_H
#define VOLUMESAVERCOUNTER_H

#include "saver_counter.h"
#include "volume_saver.h"

namespace vd {

class VolumeSaverCounter : public SaverCounter
{
    const Detector* _detector;
    std::string _volumeSaverType;
    VolumeSaver* _saver;
public:
    VolumeSaverCounter(const Detector* detector, std::string saverType, const char *name, double step);

    void save(const SavingData &sd) override;
private:
    VolumeSaver* takeSaver(std::string volumeSaverType, const char *name);
};

}

#endif // VOLUMESAVERCOUNTER_H
