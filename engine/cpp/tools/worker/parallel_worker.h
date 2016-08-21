#ifndef PARALLEL_WORKER_H
#define PARALLEL_WORKER_H

#include <pthread.h>
#include "worker_queue.h"

namespace vd
{

class ParallelWorker
{
    pthread_mutex_t _mutex = PTHREAD_MUTEX_INITIALIZER;
    pthread_cond_t _cond = PTHREAD_COND_INITIALIZER;
    pthread_t _thread;

    bool _stop = false;

    WorkerQueue _queue;

    static void *threadFunc(void *instance);

public:
    ParallelWorker();

    void push(Job *job);
    void stop();

private:
    ParallelWorker(const ParallelWorker &) = delete;
    ParallelWorker(ParallelWorker &&) = delete;
    ParallelWorker &operator = (const ParallelWorker &) = delete;
    ParallelWorker &operator = (ParallelWorker &&) = delete;

    void run();
};

}

#endif // PARALLEL_WORKER_H
