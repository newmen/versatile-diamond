#ifndef PARALLEL_WORKER_H
#define PARALLEL_WORKER_H

#include <thread>
#include "worker_queue.h"

namespace vd
{

class ParallelWorker
{
    std::thread _thread;
    WorkerQueue _queue;

    static volatile bool __stop;
    static void parallelFunc(ParallelWorker *worker);

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
    void process();
};

}

#endif // PARALLEL_WORKER_H
