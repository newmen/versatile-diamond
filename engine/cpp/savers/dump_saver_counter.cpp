#include "dump_saver_counter.h"
#include "queue/queue_item.h"

namespace vd {

DumpSaverCounter::DumpSaverCounter(uint x, uint y, const char *name, const Detector *detector, double step) : SaverCounter(step), _detector(detector)
{
    _dmpSaver = new DumpSaver(name, x, y);
}

void DumpSaverCounter::save(const SavingData &sd)
{
    _dmpSaver->save(sd.currentTime, sd.amorph, sd.crystal, _detector);
}

}
