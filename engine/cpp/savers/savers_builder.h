#ifndef SAVERS_BUILDER
#define SAVERS_BUILDER

#include "decorator/queue_item.h"

namespace vd {

class SaversBuilder
{
    double _step;
public:
    SaversBuilder(double step) : _step(step) {}

    virtual QueueItem* wrapItem(QueueItem* item) = 0;
    virtual void save(const Amorph *amorph, const Crystal *crystal);
};

}

#endif // SAVERS_BUILDER

