#ifndef DUMPSAVERBUILDER_H
#define DUMPSAVERBUILDER_H

#include "../phases/amorph.h"
#include "../phases/crystal.h"
#include "saver_builder.h"
#include "dump/dump_saver.h"
#include "detector.h"

namespace vd {

class DumpSaverBuilder : public SaverBuilder
{
    uint _x;
    uint _y;
    const Detector *_detector;
    DumpSaver *_dmpSaver;

public:
    DumpSaverBuilder(uint x,
                     uint y,
                     const Detector *detector,
                     double step) :
        SaverBuilder(step),
        _x(x),
        _y(y),
        _detector(detector) { _dmpSaver = new DumpSaver(); }

    void save(const SavingData &sd) override;
};

}

#endif // DUMPSAVERBUILDER_H
