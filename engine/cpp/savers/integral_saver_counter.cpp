#include "integral_saver_counter.h"
#include "queue/queue_item.h"

namespace vd {

IntegralSaverCounter::IntegralSaverCounter(double step, CrystalSliceSaver *csSaver) : CounterWhithSaver(step, csSaver)
{
}

void IntegralSaverCounter::save(const SavingData &sd)
{
    saver()->writeBySlicesOf(sd.crystal, sd.currentTime);
}

}
