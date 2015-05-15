#include "thread_runner.h"
#include <thread>

namespace vd
{

void ThreadRunner::saveData(QueueItem *item, double currentTime, const char *name)
{
    std::thread thr(threadSaveData, item, currentTime, name);
    thr.join();
}

void ThreadRunner::threadSaveData(QueueItem *item, double currentTime, const char *name)
{
    item->saveData(currentTime, name);
}

}
