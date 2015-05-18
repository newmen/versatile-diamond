#include "parallel_saver.h"
#include <iostream>
namespace vd
{

ParallelSaver::ParallelSaver()
{
    start();
}

void ParallelSaver::addItem(QueueItem *item, double allTime, double currentTime, const char *name)
{
    item->copyData();

    _queue.push(new qitem({item, allTime, currentTime, name}));
}

void ParallelSaver::run()
{
    while (true)
    {
        pthread_mutex_lock(&_mutex);

        while (!_queue.empty())
        {
            qitem* qi = _queue.front();
            qi->item->saveData(qi->allTime, qi->currentTime, qi->name);
            _queue.pop();
        }

        pthread_cond_wait(&_cond, &_mutex);

        pthread_mutex_unlock(&_mutex);
    }
}

void ParallelSaver::saveData()
{
    pthread_cond_signal(&_cond);
}

}
