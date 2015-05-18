#ifndef SAVER_BUILDER
#define SAVER_BUILDER

#include "decorator/queue_item.h"

namespace vd {

class SaverBuilder
{
    double _step, _accTime = 0;
public:
    SaverBuilder(double step) : _step(step) {}
    virtual ~SaverBuilder() {}

    QueueItem* wrapItem(QueueItem* item);
    void setTime(double diffTime) { _accTime += diffTime; }
    bool isNeedSave();
    void resetTime();
    virtual void save(const SavingData &sd) = 0;
};

}

#endif // SAVER_BUILDER

