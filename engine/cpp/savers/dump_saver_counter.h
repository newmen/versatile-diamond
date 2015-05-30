#ifndef DUMPSAVERCOUNTER_H
#define DUMPSAVERCOUNTER_H

#include "../phases/amorph.h"
#include "../phases/crystal.h"
#include "queue/queue_item.h"
#include "dump/dump_saver.h"
#include "detector_factory.h"
#include "saver_counter.h"

namespace vd {

template <class HB>
class DumpSaverCounter : public SaverCounter
{
    const Detector *_detector;
    DumpSaver *_dmpSaver;

public:
    DumpSaverCounter(double step, DumpSaver *dmpSaver);
    ~DumpSaverCounter();

    void save(const SavingData &sd) override;
};

/////////////////////////////////////////////////////////////////////////////////////////////////

template <class HB>
DumpSaverCounter<HB>::DumpSaverCounter(double step, DumpSaver *dmpSaver) : SaverCounter(step), _dmpSaver(dmpSaver)
{
    DetectorFactory<HB> detFact;
    _detector = detFact.create("all");
}

template <class HB>
DumpSaverCounter<HB>::~DumpSaverCounter()
{
    delete _detector;
}

template <class HB>
void DumpSaverCounter<HB>::save(const SavingData &sd)
{
    _dmpSaver->save(sd.currentTime, sd.amorph, sd.crystal, _detector);
}

}

#endif // DUMPSAVERCOUNTER_H
