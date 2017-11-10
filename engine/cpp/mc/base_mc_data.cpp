#include "base_mc_data.h"

namespace vd
{

BaseMCData::~BaseMCData()
{
    delete _counter;
}

void BaseMCData::makeCounter(uint reactionsNum)
{
    _counter = new EventsCounter(reactionsNum);
}

}
