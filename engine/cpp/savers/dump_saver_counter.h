#ifndef DUMPSAVERCOUNTER_H
#define DUMPSAVERCOUNTER_H

#include "../phases/amorph.h"
#include "../phases/crystal.h"
#include "saver_counter.h"
#include "dump/dump_saver.h"
#include "detector.h"

namespace vd {

class DumpSaverCounter : public SaverCounter
{
    const Detector *_detector;
    DumpSaver *_dmpSaver;

public:
    DumpSaverCounter(uint x, uint y, const Detector *detector, double step);

    void save(const SavingData &sd) override;
};

}

#endif // DUMPSAVERCOUNTER_H
