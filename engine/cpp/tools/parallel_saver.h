#ifndef PARALLELSAVER_H
#define PARALLELSAVER_H

#include <queue>
#include "thread.h"
#include "../savers/decorator/queue_item.h"
#include "../savers/saving_data.h"

namespace vd
{

class ParallelSaver : public Thread
{
    pthread_mutex_t _mutex = PTHREAD_MUTEX_INITIALIZER;
    pthread_cond_t _cond = PTHREAD_COND_INITIALIZER;

    struct qitem
    {
        QueueItem *item;
        double allTime;
        double currentTime;
        const char *name;
    };

    std::queue<qitem *> _queue;

public:
    ParallelSaver();

    void addItem(QueueItem *item, double allTime, double currentTime, const char *name);
    void saveData();

private:
    void run() override;
};

}

#endif // PARALLELSAVER_H
