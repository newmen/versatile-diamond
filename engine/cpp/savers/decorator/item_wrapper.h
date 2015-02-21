#ifndef ITEMWRAPPER_H
#define ITEMWRAPPER_H

#include "queue_item.h"

namespace vd {

class ItemWrapper : public QueueItem
{
    QueueItem* _target;
public:
    ItemWrapper(QueueItem* targ);

    Amorph* amorph();
    Crystal* crystal();
    bool isEmpty() { return false; }
};

}

#endif // ITEMWRAPPER_H
