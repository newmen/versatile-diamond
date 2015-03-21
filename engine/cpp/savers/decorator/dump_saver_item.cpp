#include "dump_saver_item.h"

namespace vd {

void DumpSaverItem::saveData()
{
    _svBuilder->save(amorph(), crystal());

    _target->saveData();
}

}
