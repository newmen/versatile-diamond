#ifndef DUMPSAVERCOUNTER_H
#define DUMPSAVERCOUNTER_H

#include "../phases/amorph.h"
#include "../phases/crystal.h"
#include "dump/dump_saver.h"
#include "counter_whith_saver.h"
#include "detector_factory.h"

namespace vd {

template <class HB>
class DumpSaverCounter : public CounterWhithSaver<DumpSaver>
{
    const Detector *_detector;

public:
    DumpSaverCounter(double step, DumpSaver *dmpSaver);
    ~DumpSaverCounter();

    void save(const SavingData &sd) override;
};

/////////////////////////////////////////////////////////////////////////////////////////////////

template <class HB>
DumpSaverCounter<HB>::DumpSaverCounter(double step, DumpSaver *dmpSaver) : CounterWhithSaver(step, dmpSaver)
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
    CounterWhithSaver<DumpSaver>::saver()->save(sd.currentTime, sd.amorph, sd.crystal, _detector);
}

}

#endif // DUMPSAVERCOUNTER_H
