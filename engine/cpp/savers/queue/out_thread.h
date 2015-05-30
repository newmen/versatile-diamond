#ifndef OUT_THREAD_H
#define OUT_THREAD_H

#include <pthread.h>
#include "../../tools/saving_queue.h"

namespace vd
{

class OutThread
{
    pthread_mutex_t _mutex = PTHREAD_MUTEX_INITIALIZER;
    pthread_cond_t _cond = PTHREAD_COND_INITIALIZER;
    pthread_t _thread;

    bool _stop = false;

    SavingQueue _queue;

public:
    OutThread();
    virtual ~OutThread() {}

    void push(QueueItem *item, double allTime, double currentTime, const char *name);

    void stop();

private:
    OutThread(const OutThread& copy);
    static void *thread_func(void *d);

    void run();
};

}

#endif // OUT_THREAD_H
