#include "integral_saver_counter.h"
#include "decorator/queue_item.h"

namespace vd {

void IntegralSaverCounter::save(const SavingData &sd)
{
    _csSaver->writeBySlicesOf(sd.crystal, sd.currentTime);
}

}
