#ifndef QUEUEITEM_H
#define QUEUEITEM_H

#include "../../phases/saving_amorph.h"
#include "../../phases/saving_crystal.h"
#include "../saving_data.h"

namespace vd {

class QueueItem
{
public:
    virtual ~QueueItem() {}

    virtual void saveData(double allTime, double currentTime, const char *name) = 0;
    virtual void copyData() = 0;
    virtual const SavingAmorph* amorph() = 0;
    virtual const SavingCrystal* crystal() = 0;
    virtual bool isEmpty() const = 0;
    virtual void saveData(const SavingData &sd) const = 0;

protected:
    QueueItem() = default;
};

}

#endif // QUEUEITEM_H
