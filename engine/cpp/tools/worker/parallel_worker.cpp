#include "parallel_worker.h"

namespace vd
{

volatile bool ParallelWorker::__stop = false;

ParallelWorker::ParallelWorker()
{
    _thread = std::thread(std::bind(&ParallelWorker::parallelFunc, this));
}

void ParallelWorker::parallelFunc(ParallelWorker *worker)
{
    worker->run();
}

void ParallelWorker::push(Job *job)
{
    _queue.push(job);
}

void ParallelWorker::stop()
{
    __stop = true;
    _queue.push(nullptr);
    _thread.join();
}

void ParallelWorker::run()
{
    while (!__stop)
    {
        process();
    }
}

void ParallelWorker::process()
{
    Job *job = _queue.pop();
    if (job)
    {
        job->apply();
        delete job;
    }
}

}
