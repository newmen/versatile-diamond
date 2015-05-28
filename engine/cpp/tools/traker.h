#ifndef TRAKER_H
#define TRAKER_H

#include <vector>
#include "../savers/queue/queue_item.h"
#include "../savers/saver_counter.h"

namespace vd
{

class Traker
{
    std::vector<SaverCounter *> _savers;

public:
    Traker() {}
    ~Traker();

    QueueItem *takeItem(QueueItem *soul) const;
    void add(SaverCounter* svrBilder);
    void appendTime(double diffTime) const;
};

}

#endif // TRAKER_H
