#include "dump_saver_builder.h"
#include "decorator/dump_saver_item.h"

namespace vd {

QueueItem *DumpSaverBuilder::wrapItem(QueueItem *item)
{
    return new DumpSaverItem(item, *this);
}

void DumpSaverBuilder::save(const Amorph *amorph, const Crystal *crystal, double currentTime, double diffTime)
{
    if (isNeedSave(diffTime))
        dmpSaver.save(_x, _y,currentTime, amorph, crystal, _detector);
}

}
