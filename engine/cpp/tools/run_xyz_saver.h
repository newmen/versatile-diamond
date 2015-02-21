#ifndef RUNXYZSAVER_H
#define RUNXYZSAVER_H

#include "run_volume_saver.h"

namespace vd {

class RunXYZSaver : public RunVolumeSaver
{
    std::string _volumeSaverType = "xyz";

public:
    RunXYZSaver(SaversDecorator* targ) : RunVolumeSaver(targ) {}

    void saveData(double currentTime, std::string filename);
};

}
#endif // RUNXYZSAVER_H
