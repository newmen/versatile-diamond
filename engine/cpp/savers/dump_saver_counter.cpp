#include "dump_saver_counter.h"
#include "decorator/queue_item.h"

namespace vd {

void DumpSaverCounter::save(const SavingData &sd)
{
    _dmpSaver->save(_x, _y, sd.currentTime, sd.amorph, sd.crystal, _detector);
}

}
