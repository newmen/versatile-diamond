#include "saver_counter.h"
#include "queue/item_wrapper.h"

namespace vd {

QueueItem *SaverCounter::wrapItem(QueueItem *item)
{
    if (isNeedSave())
    {
        resetTime();
        return new ItemWrapper(item, this);
    }

    return item;
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
