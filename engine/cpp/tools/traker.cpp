#include "traker.h"

namespace vd {

QueueItem *Traker::takeItem(QueueItem* soul)
{
    QueueItem *item = soul;
    for (uint i = 0; i < _queue.size(); ++i)
    {
        if (_queue[i]->isNeedSave())
        {
            item = _queue[i]->wrapItem(item);
            _queue[i]->resetTime();
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
    for (SaverBuilder *bldr : _queue)
        bldr->setTime(diffTime);
}

}
