#include "item_wrapper.h"

namespace vd {

ItemWrapper::~ItemWrapper()
{
    delete _target;
    delete _svBuilder;
}

void ItemWrapper::saveData(double currentTime, const char *name)
{
    _svBuilder->save(amorph(), crystal(), name, currentTime);
    _target->saveData(currentTime, name);
}

void ItemWrapper::copyData()
{
    _target->copyData();
}

const SavingAmorph *ItemWrapper::amorph()
{
    return _target->amorph();
}

const SavingCrystal *ItemWrapper::crystal()
{
    return _target->crystal();
}

}
