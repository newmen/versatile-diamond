#include "traker.h"

namespace vd {

Traker::~Traker()
{
    for (SaverCounter *bldr : _queue)
    {
        delete bldr;
    }
}

QueueItem *Traker::takeItem(QueueItem* soul)
{
    QueueItem *item = soul;
    for (SaverCounter *bldr : _queue)
    {
        item = bldr->wrapItem(item);
    }
    return item;
}

void Traker::add(SaverCounter *svrBilder)
{
    _queue.push_back(svrBilder);
}

void Traker::setTime(double diffTime)
{
    for (SaverCounter *bldr : _queue)
    {
        bldr->appendTime(diffTime);
    }
}

}
