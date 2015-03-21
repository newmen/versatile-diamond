#include "integral_saver_builder.h"
#include "crystal_slice_saver.h"
#include "decorator/integral_saver_item.h"

namespace vd {

QueueItem *IntegralSaverBuilder::wrapItem(QueueItem *item)
{
    return new IntegralSaverItem(item, *this);
}

void IntegralSaverBuilder::save(Crystal *crystal)
{
    CrystalSliceSaver csSaver(_name, _sliceMaxNum, _targetTypes);
    csSaver.writeBySlicesOf(crystal, _currentTime);
}

}
