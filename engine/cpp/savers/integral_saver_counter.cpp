#include "integral_saver_counter.h"
#include "queue/queue_item.h"

namespace vd {

IntegralSaverCounter::IntegralSaverCounter(double step, CrystalSliceSaver *csSaver) : SaverCounter(step), _csSaver(csSaver)
{
}

void IntegralSaverCounter::save(const SavingData &sd)
{
    _csSaver->writeBySlicesOf(sd.crystal, sd.currentTime);
}

}
