#include "item_wrapper.h"

namespace vd {

ItemWrapper::ItemWrapper(SaversDecorator *targ) { _target = targ; }

void ItemWrapper::copyData()
{
    _target->copyData();
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
