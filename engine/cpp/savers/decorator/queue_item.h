#ifndef QUEUEITEM_H
#define QUEUEITEM_H

#include "../../phases/amorph.h"
#include "../../phases/crystal.h"

namespace vd {

class QueueItem
{
public:
    QueueItem();

    virtual void saveData(double currentTime, double diffTime) = 0;
    virtual void copyData() = 0;
    virtual const Amorph* amorph() = 0;
    virtual const Crystal* crystal() = 0;
    virtual bool isEmpty() = 0;
};

}

#endif // QUEUEITEM_H
