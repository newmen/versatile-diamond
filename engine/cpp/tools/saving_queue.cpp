#include "saving_queue.h"

namespace vd
{

void SavingQueue::push(QueueItem *item, double allTime, double currentTime, const char *name)
{
    item->copyData();
    _queue.push(new qitem({item, allTime, currentTime, name}));
}

void SavingQueue::process()
{
    while (!_queue.empty())
    {
        qitem* qi = _queue.front();
        qi->item->saveData(qi->allTime, qi->currentTime, qi->name);
        delete qi->item;
        delete qi;
        _queue.pop();
    }
}

}
