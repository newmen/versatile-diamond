#ifndef ITEMWRAPPER_H
#define ITEMWRAPPER_H

#include "queue_item.h"
#include "../saver_builder.h"

namespace vd {

class ItemWrapper : public QueueItem
{
    QueueItem *_target;
    SaverBuilder *_svBuilder;
public:
    ItemWrapper(QueueItem *targ, SaverBuilder *svBuilder) : _target(targ), _svBuilder(svBuilder) {}
    ~ItemWrapper();

    void saveData(double currentTime, const char *name) override;
    void copyData() override;
    const SavingAmorph *amorph() override;
    const SavingCrystal *crystal() override;
    bool isEmpty() override { return false; }
};

}

#endif // ITEMWRAPPER_H
