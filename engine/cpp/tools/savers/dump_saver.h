#ifndef DUMP_SAVER_H
#define DUMP_SAVER_H

#include "../../phases/amorph.h"
#include "../../phases/crystal.h"
#include "detector.h"
#include <fstream>

namespace vd {

class DumpSaver
{
    std::ofstream _outFile;
public:
    DumpSaver();
    ~DumpSaver();

    void save(double currentTime, const Amorph *amorph, const Crystal *crystal, const Detector *detector);
};

}
#endif // DUMP_SAVER_H
