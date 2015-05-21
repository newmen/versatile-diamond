#include "saving_queue.h"

namespace vd
{

SavingQueue::SavingQueue()
{
    init();
}

void SavingQueue::push(QueueItem *item, double allTime, double currentTime, const char *name)
{
    item->copyData();

    _queue.push(new qitem({item, allTime, currentTime, name}));
}

void SavingQueue::run()
{
    while (true)
    {
        pthread_mutex_lock(&_mutex);

        process();
        pthread_cond_wait(&_cond, &_mutex);

        pthread_mutex_unlock(&_mutex);
    }
}

void SavingQueue::process()
{
    while (!_queue.empty())
    {
        qitem* qi = _queue.front();
        qi->item->saveData(qi->allTime, qi->currentTime, qi->name);
        _queue.pop();
    }
}

void SavingQueue::saveData()
{
    pthread_cond_signal(&_cond);
}

}
