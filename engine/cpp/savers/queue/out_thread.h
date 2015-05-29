#ifndef OUT_THREAD_H
#define OUT_THREAD_H

#include <pthread.h>

namespace vd
{

template <class Q>
class OutThread
{
    pthread_mutex_t _mutex = PTHREAD_MUTEX_INITIALIZER;
    pthread_cond_t _cond = PTHREAD_COND_INITIALIZER;
    pthread_t _thread;

    bool _stopSave = false;

    Q _queue; //Need methods process and push.

public:
    OutThread();
    virtual ~OutThread() {}

    template <class... Args>
    void push(Args... args)
    {
        _queue.push(args...);
        pthread_cond_signal(&_cond);
    }

    void stopSave();

private:
    OutThread(const OutThread& copy);
    static void *thread_func(void *d);

    void run();
};

///////////////////////////////////////////////////////////////////////////////////////////////

template <class Q>
OutThread<Q>::OutThread()
{
    pthread_create(&_thread, nullptr, OutThread::thread_func, (void*)this);
}

template <class Q>
void OutThread<Q>::run()
{
    while (!_stopSave)
    {
        pthread_mutex_lock(&_mutex);

        _queue.process();
        pthread_cond_wait(&_cond, &_mutex);

        pthread_mutex_unlock(&_mutex);
    }
    _queue.process();
}

template <class Q>
void *OutThread<Q>::thread_func(void *d)
{
    static_cast<OutThread *>(d)->run();
    return nullptr;
}

template <class Q>
void OutThread<Q>::stopSave()
{
    _stopSave = true;
    pthread_join(_thread, nullptr);
}

}

#endif // OUT_THREAD_H
