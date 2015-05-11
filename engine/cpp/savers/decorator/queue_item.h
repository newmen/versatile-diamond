#ifndef QUEUEITEM_H
#define QUEUEITEM_H

#include "../../phases/saving_amorph.h"
#include "../../phases/saving_crystal.h"

namespace vd {

class QueueItem
{
public:
    QueueItem() {}
    virtual ~QueueItem() {}

    virtual void saveData(double currentTime, const char *name) = 0;
    virtual void copyData() = 0;
    virtual const SavingAmorph* amorph() = 0;
    virtual const SavingCrystal* crystal() = 0;
    virtual bool isEmpty() = 0;
};

}

#endif // QUEUEITEM_H
