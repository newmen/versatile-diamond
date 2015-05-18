#ifndef PARALLELSAVER_H
#define PARALLELSAVER_H

#include <vector>
#include "thread.h"
#include "../savers/decorator/queue_item.h"
#include "../savers/saving_data.h"

namespace vd
{

class ParallelSaver : public Thread
{
    struct qitem
    {
        QueueItem *item;
        double allTime;
        double currentTime;
        const char *name;
    };

    std::vector<qitem *> _queue;

public:
    ParallelSaver() {}

    void addItem(QueueItem *item, double allTime, double currentTime, const char *name);
    void saveData();

private:
    void run() override;
};

}

#endif // PARALLELSAVER_H
