#ifndef DUMP_SAVER_H
#define DUMP_SAVER_H

#include "../../phases/saving_amorph.h"
#include "../../phases/saving_crystal.h"
#include "../../savers/detector.h"
#include <fstream>

namespace vd {

class DumpSaver
{
    std::ofstream _outFile;
    uint _x, _y;
public:
    DumpSaver(uint x, uint y);
    ~DumpSaver();

    void save(double currentTime, const SavingAmorph *amorph, const SavingCrystal *crystal, const Detector *detector);
};

}
#endif // DUMP_SAVER_H
