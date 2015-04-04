#ifndef ITEMWRAPPER_H
#define ITEMWRAPPER_H

#include "queue_item.h"
#include "../savers_builder.h"

namespace vd {

class ItemWrapper : public QueueItem
{
    QueueItem* _target;
    SaversBuilder* _svBuilder;
public:
    ItemWrapper(QueueItem* targ, SaversBuilder* svBuilder) : _target(targ), _svBuilder(svBuilder) {}

    void copyData() override;
    void saveData(double currentTime, double diffTime) override;
    Amorph* amorph() override;
    Crystal* crystal() override;
    bool isEmpty() override { return false; }
};

}

#endif // ITEMWRAPPER_H
