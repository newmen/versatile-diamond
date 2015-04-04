#include "integral_saver_builder.h"
#include "decorator/integral_saver_item.h"

namespace vd {

QueueItem *IntegralSaverBuilder::wrapItem(QueueItem *item)
{
    return new IntegralSaverItem(item, *this);
}

void IntegralSaverBuilder::save(const Amorph *, const Crystal *crystal, double currentTime, double diffTime)
{
    if (isNeedSave(diffTime))
        csSaver.writeBySlicesOf(crystal, currentTime);
}

}
