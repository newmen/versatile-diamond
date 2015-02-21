#include "xyz_queue_item.h"

namespace vd {

void XYZQueueItem::saveData(double currentTime, std::string filename)
{

    _target->saveData(currentTime, filename);
}

}
