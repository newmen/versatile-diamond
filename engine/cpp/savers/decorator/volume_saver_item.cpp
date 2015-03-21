#include "volume_saver_item.h"

namespace vd {

void VolumeSaverItem::saveData()
{
    _svBuilder->save(amorph(),crystal());

    _target->saveData();
}

}

