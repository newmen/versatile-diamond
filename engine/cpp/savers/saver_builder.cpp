#include "saver_builder.h"
#include "decorator/item_wrapper.h"

namespace vd {

QueueItem *SaverBuilder::wrapItem(QueueItem *item)
{
    return new ItemWrapper(item, this);
}

bool SaverBuilder::isNeedSave()
{
    if (_accTime >= _step)
    {
        return true;
    }
    return false;
}

void SaverBuilder::resetTime()
{
    _accTime -= _step;
    assert(_accTime >= 0);
}

}
