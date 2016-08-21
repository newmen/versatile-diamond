#ifndef COMMON_MC_DATA_H
#define COMMON_MC_DATA_H

#include "../atoms/atom.h"
#include "../reactions/reaction.h"
#include "events_counter.h"
#include "random_generator.h"

namespace vd
{

class CommonMCData
{
    RandomGenerator _generator;
    EventsCounter *_counter = nullptr;

public:
    CommonMCData() = default;
    ~CommonMCData();

    double rand(double maxValue);

    void makeCounter(uint reactionsNum);
    EventsCounter *counter() const { return _counter; }

private:
    CommonMCData(const CommonMCData &) = delete;
    CommonMCData(CommonMCData &&) = delete;
    CommonMCData &operator = (const CommonMCData &) = delete;
    CommonMCData &operator = (CommonMCData &&) = delete;
};

}

#endif // COMMON_MC_DATA_H
