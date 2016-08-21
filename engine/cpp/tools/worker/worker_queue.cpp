#include "worker_queue.h"

namespace vd
{

void WorkerQueue::push(Job *job)
{
    _queue.push(job);
}

void WorkerQueue::process()
{
    while (!_queue.empty())
    {
        Job* job = _queue.front();
        _queue.pop();
        job->apply();
        delete job;
    }
}

}
