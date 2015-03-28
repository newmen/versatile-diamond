#include "dump_saver_builder.h"
#include "decorator/dump_saver_item.h"

namespace vd {

QueueItem *DumpSaverBuilder::wrapItem(QueueItem *item)
{
    return new DumpSaverItem(item, *this);
}

void DumpSaverBuilder::save(const Amorph *amorph, const Crystal *crystal, double currentTime)
{
    dmpSaver.save(_x, _y,currentTime, amorph, crystal, _detector);
}

}
