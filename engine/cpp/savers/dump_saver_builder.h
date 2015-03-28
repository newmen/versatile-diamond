#ifndef DUMPSAVERBUILDER_H
#define DUMPSAVERBUILDER_H

#include "../phases/amorph.h"
#include "../phases/crystal.h"
#include "savers_builder.h"
#include "dump/dump_saver.h"
#include "detector.h"

namespace vd {

class DumpSaverBuilder : public SaversBuilder
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
        SaversBuilder(step),
        _x(x),
        _y(y),
        _detector(detector) { _dmpSaver = new DumpSaver(); }

    QueueItem* wrapItem(QueueItem* item);
    void save(const Amorph* amorph, const Crystal* crystal, double currentTime);
};

}

#endif // DUMPSAVERBUILDER_H
