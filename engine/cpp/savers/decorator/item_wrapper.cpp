#include "item_wrapper.h"

namespace vd {

ItemWrapper::ItemWrapper(SaversDecorator *targ) { _target = targ; }

void ItemWrapper::copyData()
{
    _target->copyData();
}

void ItemWrapper::saveData(double currentTime, double diffTime)
{
    _svBuilder->save(amorph(),crystal(), currentTime, diffTime);

    _target->saveData(currentTime, diffTime);
}

Amorph *ItemWrapper::amorph()
{
    return _target->amorph();
}

Crystal *ItemWrapper::crystal()
{
    return _target->crystal();
}

}
