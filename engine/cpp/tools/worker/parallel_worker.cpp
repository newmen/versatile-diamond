#include "parallel_worker.h"

namespace vd
{

ParallelWorker::ParallelWorker()
{
    pthread_create(&_thread, nullptr, ParallelWorker::threadFunc, (void *)this);
}

void *ParallelWorker::threadFunc(void *instance)
{
    static_cast<ParallelWorker *>(instance)->run();
    return nullptr;
}

void ParallelWorker::push(Job *job)
{
    _queue.push(job);
    pthread_cond_signal(&_cond);
}

void ParallelWorker::stop()
{
    _stop = true;
    if (pthread_mutex_trylock(&_mutex) == 0)
    {
        pthread_mutex_unlock(&_mutex);
    }
    else
    {
        pthread_cond_signal(&_cond);
    }
    pthread_join(_thread, nullptr);
}

void ParallelWorker::run()
{
    while (!_stop)
    {
        pthread_mutex_lock(&_mutex);

        _queue.process();
        pthread_cond_wait(&_cond, &_mutex);

        pthread_mutex_unlock(&_mutex);
    }
    _queue.process();
}

}
