#ifndef VOLUMESAVERITEM_H
#define VOLUMESAVERITEM_H

#include "item_wrapper.h"
#include "savers/volume_saver_factory.h"
#include "savers/detector_factory.h"

namespace vd {

class VolumeSaverItem : public ItemWrapper
{
public:
    VolumeSaverItem(QueueItem* targ, SaversBuilder* svBuilder) : ItemWrapper(targ, svBuilder) {}

    void saveData();
};

}

#endif // VOLUMESAVERITEM_H
