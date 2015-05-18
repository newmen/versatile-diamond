#include "parallel_saver.h"

namespace vd
{

void ParallelSaver::addItem(QueueItem *item, double allTime, double currentTime, const char *name)
{
    item->copyData();
    _queue.push_back(new qitem({item, allTime, currentTime, name}));
}

void ParallelSaver::run()
{
    qitem* qi = _queue.back();
    _queue.pop_back();
    qi->item->saveData(qi->allTime, qi->currentTime, qi->name);
}

void ParallelSaver::saveData()
{
    if (_queue.size() != 0)
        start();
}

}
