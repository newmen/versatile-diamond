#include "saver_counter.h"
#include "decorator/item_wrapper.h"

namespace vd {

QueueItem *SaverCounter::wrapItem(QueueItem *item)
{
    return new ItemWrapper(item, this);
}

bool SaverCounter::isNeedSave()
{
    if (_accTime >= _step)
    {
        return true;
    }
    return false;
}

void SaverCounter::resetTime()
{
    _accTime -= _step;
    assert(_accTime >= 0);
}

}
