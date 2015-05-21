#ifndef TRAKER_H
#define TRAKER_H

#include <vector>
#include "../savers/queue/queue_item.h"
#include "../savers/saver_counter.h"

namespace vd
{

class Traker
{
    std::vector<SaverCounter *> _queue;

public:
    Traker() {}
    ~Traker();

    QueueItem *takeItem(QueueItem *soul);
    void pushItem(SaverCounter* svrBilder);
    void setTime(double diffTime);
};

}

#endif // TRAKER_H
