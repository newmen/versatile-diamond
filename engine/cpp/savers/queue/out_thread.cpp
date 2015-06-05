#include "out_thread.h"

namespace vd
{

OutThread::OutThread()
{
    pthread_create(&_thread, nullptr, OutThread::thread_func, (void*)this);
}

void OutThread::run()
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

void *OutThread::thread_func(void *d)
{
    static_cast<OutThread *>(d)->run();
    return nullptr;
}

void OutThread::stop()
{
    _stop = true;
    pthread_join(_thread, nullptr);
}

void OutThread::push(QueueItem *item, double allTime, double currentTime, const char *name)
{
    _queue.push(item, allTime, currentTime, name);
    pthread_cond_signal(&_cond);
}

}
