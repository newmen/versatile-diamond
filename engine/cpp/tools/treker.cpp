#include "treker.h"

namespace vd {

QueueItem *Treker::takeItem(QueueItem* soul)
{
    return recursiveTakeItem(soul, 0);
}

QueueItem *Treker::recursiveTakeItem(QueueItem *item, int i)
{
    if (i <= _queue.size())
    {
        item = _queue[i]->wrapItem(item);
        return recursiveTakeItem(item, i++);
    }
    else
        return item;
}

}
