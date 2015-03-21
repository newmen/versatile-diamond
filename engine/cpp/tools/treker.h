#ifndef TREKER_H
#define TREKER_H

#include <vector>
#include "../savers/decorator/queue_item.h"
#include "../savers/savers_builder.h"

namespace vd {

class Treker
{
    std::vector<SaversBuilder*> _queue;

public:
    Treker() {}
    QueueItem* takeItem(QueueItem *soul);
protected:
    QueueItem* recursiveTakeItem(QueueItem *item, int i);
};

}

#endif // TREKER_H
