#ifndef INTEGRALSAVERITEM_H
#define INTEGRALSAVERITEM_H

#include "item_wrapper.h"

namespace vd {

class IntegralSaverItem : public ItemWrapper
{
public:
    IntegralSaverItem(QueueItem* targ, SaversBuilder* svBuilder) : ItemWrapper(targ, svBuilder) {}

    void saveData();
};

}

#endif // INTEGRALSAVERITEM_H
