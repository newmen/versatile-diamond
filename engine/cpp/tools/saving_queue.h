#ifndef SAVING_QUEUE_H
#define SAVING_QUEUE_H

#include <queue>
#include "../savers/queue/out_thread.h"
#include "../savers/queue/queue_item.h"

namespace vd
{

class SavingQueue
{
    struct qitem
    {
        QueueItem *item;
        double allTime;
        double currentTime;
        const char *name;
    };

    std::queue<qitem *> _queue;

public:
    SavingQueue() {}

    void push(QueueItem *item, double allTime, double currentTime, const char *name);
    void process();
};

}

#endif // SAVING_QUEUE_H
