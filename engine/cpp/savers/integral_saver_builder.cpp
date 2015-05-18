#include "integral_saver_builder.h"
#include "decorator/queue_item.h"

namespace vd {

void IntegralSaverBuilder::save(const SavingData &sd)
{
    _csSaver->writeBySlicesOf(sd.crystal, sd.currentTime);
}

}
