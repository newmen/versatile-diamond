#include "integral_saver_builder.h"
#include "decorator/queue_item.h"

namespace vd {

void IntegralSaverBuilder::save(const SavingAmorph *, const SavingCrystal *crystal, const char *, double currentTime)
{
    _csSaver->writeBySlicesOf(crystal, currentTime);
}

}
