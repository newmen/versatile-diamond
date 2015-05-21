#include "integral_saver_counter.h"
#include "queue/queue_item.h"

namespace vd {

IntegralSaverCounter::IntegralSaverCounter(const char *name, uint sliceMaxNum, const std::initializer_list<ushort> &targetTypes, double step) :
    SaverCounter(step),
    _name(name),
    _sliceMaxNum(sliceMaxNum),
    _targetTypes(targetTypes)
{
    _csSaver = new CrystalSliceSaver(_name, _sliceMaxNum, _targetTypes);
}

void IntegralSaverCounter::save(const SavingData &sd)
{
    _csSaver->writeBySlicesOf(sd.crystal, sd.currentTime);
}

}
