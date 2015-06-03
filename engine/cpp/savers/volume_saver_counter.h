#ifndef VOLUMESAVERCOUNTER_H
#define VOLUMESAVERCOUNTER_H

#include "saver_counter.h"
#include "volume_saver.h"
#include "counter_whith_saver.h"

namespace vd {

class VolumeSaverCounter : public CounterWhithSaver<VolumeSaver>
{
    const Detector *_detector;

public:
    VolumeSaverCounter(const Detector* detector, VolumeSaver *saver, double step);
    ~VolumeSaverCounter();

    void save(const SavingData &sd) override;
};

}

#endif // VOLUMESAVERCOUNTER_H
