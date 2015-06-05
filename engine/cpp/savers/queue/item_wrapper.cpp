#include "item_wrapper.h"

namespace vd
{

ItemWrapper::ItemWrapper(QueueItem *targ, SaverCounter *svBuilder) : _target(targ), _counter(svBuilder) {}

ItemWrapper::~ItemWrapper()
{
    delete _target;
}

void ItemWrapper::saveData(double allTime, double currentTime, const char *name)
{
    saveData(SavingData({amorph(), crystal(), allTime, currentTime, name}));
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
    _counter->save(sd);
    _target->saveData(sd);
}

}
