#include "worker_queue.h"

namespace vd
{

void WorkerQueue::push(Job *job)
{
    std::unique_lock<std::mutex> lock(_mutex);
    _queue.push(job);
    lock.unlock();
    _cond.notify_one();
}

Job *WorkerQueue::pop()
{
    std::unique_lock<std::mutex> lock(_mutex);
    while (_queue.empty())
    {
        _cond.wait(lock);
    }

    Job* job = _queue.front();
    _queue.pop();
    return job;
}

}
