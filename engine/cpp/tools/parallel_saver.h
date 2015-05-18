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
    std::vector<const QueueItem*> _queue;

public:
    ParallelSaver();

    void addItem(QueueItem *item, double allTime, double currentTime, const char *name);

private:
    void saveData();
};

}

#endif // PARALLELSAVER_H
