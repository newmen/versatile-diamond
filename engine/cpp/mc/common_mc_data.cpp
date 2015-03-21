#include "common_mc_data.h"
#include <algorithm>
#include <iostream>

namespace vd
{

CommonMCData::~CommonMCData()
{
    delete _counter;
}

double CommonMCData::rand(double maxValue)
{
    return _generator.rand(maxValue);
}

void CommonMCData::makeCounter(uint reactionsNum)
{
    _counter = new Counter(reactionsNum);
}

}
