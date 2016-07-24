#include "traker.h"

namespace vd {

Traker::~Traker()
{
    for (SaverCounter *bldr : _savers)
    {
        delete bldr;
    }
}

QueueItem *Traker::takeItem(QueueItem* soul) const
{
    QueueItem *item = soul;
    for (SaverCounter *bldr : _savers)
    {
        item = bldr->wrapItem(item);
    }
    return item;
}

void Traker::add(SaverCounter *counter)
{
    _savers.push_back(counter);
}

void Traker::appendTime(double diffTime)
{
    for (SaverCounter *bldr : _savers)
    {
        bldr->appendTime(diffTime);
    }
}

}
