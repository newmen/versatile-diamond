#ifndef XYZQUEUEITEM_H
#define XYZQUEUEITEM_H

#include "volume_saver_item.h"
#include "../xyz_saver.h"

namespace vd {

class XYZQueueItem : VolumeSaverItem
{


public:
    XYZQueueItem(QueueItem* targ, XYZSaver saver) : VolumeSaverItem(targ), _saver(saver) {}

    void saveData(double currentTime, std::string filename);
};

}

#endif // XYZQUEUEITEM_H
