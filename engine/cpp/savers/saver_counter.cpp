#include "saver_counter.h"
#include "queue/item_wrapper.h"

namespace vd {

QueueItem *SaverCounter::wrapItem(QueueItem *item)
{
    if (_accTime >= _step)
    {
        _accTime -= _step;
        return new ItemWrapper(item, this);
    }

    return item;
}

}
