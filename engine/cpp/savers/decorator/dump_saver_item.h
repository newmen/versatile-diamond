#ifndef DUMPSAVERITEM_H
#define DUMPSAVERITEM_H

#include "item_wrapper.h"

namespace vd {

class DumpSaverItem : public ItemWrapper
{
public:
    DumpSaverItem(QueueItem* targ, SaversBuilder* svBuilder) : ItemWrapper(targ, svBuilder) {}

    void saveData();
};

}

#endif // DUMPSAVERITEM_H
