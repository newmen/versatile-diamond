#include "item_wrapper.h"

namespace vd {

ItemWrapper::~ItemWrapper()
{
    delete _target;
    delete _svBuilder;
}

void ItemWrapper::saveData(double allTime, double currentTime, const char *name)
{
    _target->saveData(SavingData({amorph(), crystal(), allTime, currentTime, name}));
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

void ItemWrapper::saveData(const SavingData &sd)
{
    _svBuilder->save(sd);
}

}
