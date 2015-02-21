#include "run_xyz_saver.h"

namespace vd {

void RunXYZSaver::saveData(double currentTime, std::string filename)
{
    takeSaver(_volumeSaverType, filename)->save(currentTime, amorph(), crystal(), takeDetector(/*detectorType*/));
    _target->saveData(currentTime, filename);
}

}
