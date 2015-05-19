#include "item_wrapper.h"

namespace vd
{

ItemWrapper::~ItemWrapper()
{
    delete _target;
    delete _svBuilder;
}

void ItemWrapper::saveData(double allTime, double currentTime, const char *name)
{
    SavingData sd({amorph(), crystal(), allTime, currentTime, name});
    _svBuilder->save(sd);
    _target->saveData(sd);
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

void ItemWrapper::saveData(const SavingData &sd) const
{
    _svBuilder->save(sd);
    _target->saveData(sd);
}

}
