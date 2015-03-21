#include "integral_saver_item.h"

namespace vd {

void IntegralSaverItem::saveData()
{
    _svBuilder->save(amorph(), crystal());

    _target->saveData();
}

}
