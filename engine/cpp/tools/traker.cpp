#include "traker.h"

namespace vd {

Traker::~Traker()
{
//    delete _savers;
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

void Traker::add(SaverCounter *svrBilder)
{
    _savers.push_back(svrBilder);
}

void Traker::appendTime(double diffTime) const
{
    for (SaverCounter *bldr : _savers)
    {
        bldr->appendTime(diffTime);
    }
}

}
