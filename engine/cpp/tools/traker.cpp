#include "traker.h"

namespace vd {

QueueItem *Traker::takeItem(QueueItem* soul)
{
    QueueItem *item = soul;
    for (SaverBuilder *bldr : _queue)
    {
        if (bldr->isNeedSave())
        {
            item = bldr->wrapItem(item);
            bldr->resetTime();
        }
    }
    return item;
}

void Traker::addItem(SaverBuilder *svrBilder)
{
    _queue.push_back(svrBilder);
}

void Traker::setTime(double diffTime)
{
    _currentTime += diffTime;
    for (SaverBuilder *bldr : _queue)
        bldr->setTime(diffTime);
}

}
