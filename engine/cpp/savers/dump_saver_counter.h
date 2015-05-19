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
    uint _x;
    uint _y;
    const Detector *_detector;
    DumpSaver *_dmpSaver;

public:
    DumpSaverCounter(uint x,
                     uint y,
                     const Detector *detector,
                     double step) :
        SaverCounter(step),
        _x(x),
        _y(y),
        _detector(detector) { _dmpSaver = new DumpSaver(); }

    void save(const SavingData &sd) override;
};

}

#endif // DUMPSAVERCOUNTER_H
