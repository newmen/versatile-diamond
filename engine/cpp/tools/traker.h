#ifndef TRAKER_H
#define TRAKER_H

#include <vector>
#include "../savers/decorator/queue_item.h"
#include "../savers/saver_builder.h"

namespace vd {

class Traker
{
    std::vector<SaverBuilder*> _queue;
    double _currentTime = 0;
public:
    Traker() {}
    QueueItem* takeItem(QueueItem *soul);
    void addItem(SaverBuilder* svrBilder);
    void setTime(double diffTime);
};

}

#endif // TRAKER_H
