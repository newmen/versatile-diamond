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

    void copyData();
    Amorph* amorph();
    Crystal* crystal();
    bool isEmpty() { return false; }
};

}

#endif // ITEMWRAPPER_H
