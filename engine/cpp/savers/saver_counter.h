#ifndef SAVER_COUNTER
#define SAVER_COUNTER

#include "decorator/queue_item.h"

namespace vd {

class SaverCounter
{
    double _step, _accTime = 0;

public:
    virtual ~SaverCounter() {}

    QueueItem* wrapItem(QueueItem* item);
    void setTime(double diffTime) { _accTime += diffTime; }
    bool isNeedSave();
    void resetTime();
    virtual void save(const SavingData &sd) = 0;

protected:
    SaverCounter(double step) : _step(step) {}
};

}

#endif // SAVER_COUNTER

