#ifndef SAVING_QUEUE_H
#define SAVING_QUEUE_H

#include <queue>
#include "../savers/queue/out_thread.h"
#include "../savers/queue/queue_item.h"
#include "../savers/queue/saving_data.h"

namespace vd
{

class SavingQueue : public OutThread
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

    bool _stopSave = false;
    std::queue<qitem *> _queue;

public:
    SavingQueue();
    ~SavingQueue();

    void push(QueueItem *item, double allTime, double currentTime, const char *name);
    void saveData();

private:
    void run() override;
    void process();
};

}

#endif // SAVING_QUEUE_H
