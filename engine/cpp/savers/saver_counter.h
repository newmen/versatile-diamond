#ifndef SAVER_COUNTER
#define SAVER_COUNTER

#include "queue/queue_item.h"

namespace vd {

class SaverCounter
{
    double _step, _accTime = 0;

public:
    virtual ~SaverCounter() {}

    QueueItem* wrapItem(QueueItem* item);
    void appendTime(double diffTime) { _accTime += diffTime; }

    virtual void save(const SavingData &sd) = 0;

protected:
    SaverCounter(double step) : _step(step) {}
};

}

#endif // SAVER_COUNTER

