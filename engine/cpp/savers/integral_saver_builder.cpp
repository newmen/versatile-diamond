#include "integral_saver_builder.h"
#include "decorator/integral_saver_item.h"

namespace vd {

QueueItem *IntegralSaverBuilder::wrapItem(QueueItem *item)
{
    return new IntegralSaverItem(item, *this);
}

void IntegralSaverBuilder::save(const Amorph *amorph, const Crystal *crystal, double currentTime)
{
    csSaver.writeBySlicesOf(crystal, currentTime);
}

}
