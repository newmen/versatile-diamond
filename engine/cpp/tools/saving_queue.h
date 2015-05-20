#ifndef SAVING_QUEUE_H
#define SAVING_QUEUE_H

#include <queue>
#include "thread.h"
#include "../savers/decorator/queue_item.h"
#include "../savers/saving_data.h"

namespace vd
{

class SavingQueue : public Thread
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
    SavingQueue();
    ~SavingQueue();

    void addItem(QueueItem *item, double allTime, double currentTime, const char *name);
    void saveData();

private:
    void run() override;
};

}

#endif // SAVING_QUEUE_H
