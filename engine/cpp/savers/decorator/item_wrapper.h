#ifndef ITEMWRAPPER_H
#define ITEMWRAPPER_H

#include "queue_item.h"
#include "../saver_builder.h"
#include "../saving_data.h"

namespace vd {

class ItemWrapper : public QueueItem
{
    QueueItem *_target;
    SaverBuilder *_svBuilder;

public:
    ItemWrapper(QueueItem *targ, SaverBuilder *svBuilder) : _target(targ), _svBuilder(svBuilder) {}
    ~ItemWrapper();

    void saveData(double allTime, double currentTime, const char *name) override;
    void copyData() override;
    const SavingAmorph *amorph() override;
    const SavingCrystal *crystal() override;
    bool isEmpty() const override { return false; }

protected:
    void saveData(const SavingData &sd) const override;
};

}

#endif // ITEMWRAPPER_H
