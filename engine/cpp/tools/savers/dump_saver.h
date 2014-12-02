#ifndef DUMP_SAVER_H
#define DUMP_SAVER_H

#include "../../phases/amorph.h"
#include "../../phases/crystal.h"
#include <fstream>

namespace vd {

class DumpSaver
{
    std::ofstream *_outFile;
public:
    DumpSaver();
    ~DumpSaver();

    void save(double currentTime, const Amorph *amorph, const Crystal *crystal);
};

}
#endif // DUMP_SAVER_H
