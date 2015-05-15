#ifndef THREADRUNNER_H
#define THREADRUNNER_H

#include <mutex>
#include "../savers/decorator/queue_item.h"

namespace vd
{

class ThreadRunner
{
    std::mutex _lockUnit;
public:
    ThreadRunner() { _lockUnit.lock(); }
    ~ThreadRunner() { _lockUnit.unlock(); }

    void saveData(QueueItem *item, double currentTime, const char *name);
private:
    static void threadSaveData(QueueItem *item, double currentTime, const char *name);
};

}
#endif // THREADRUNNER_H
