#ifndef WORKER_QUEUE_H
#define WORKER_QUEUE_H

#include <queue>
#include <mutex>
#include <condition_variable>
#include "job.h"

namespace vd
{

class WorkerQueue
{
    std::queue<Job *> _queue;
    std::mutex _mutex;
    std::condition_variable _cond;

public:
    WorkerQueue() = default;

    void push(Job *job);
    Job *pop();
};

}

#endif // WORKER_QUEUE_H
