#ifndef WORKER_QUEUE_H
#define WORKER_QUEUE_H

#include <queue>
#include "job.h"

namespace vd
{

class WorkerQueue
{
    std::queue<Job *> _queue;

public:
    WorkerQueue() = default;

    void push(Job *job);
    void process();
};

}

#endif // WORKER_QUEUE_H
