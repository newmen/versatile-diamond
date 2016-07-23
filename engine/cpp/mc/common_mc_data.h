#ifndef COMMON_MC_DATA_H
#define COMMON_MC_DATA_H

#include "../atoms/atom.h"
#include "../reactions/reaction.h"
#include "counter.h"
#include "random_generator.h"

namespace vd
{

class CommonMCData
{
    RandomGenerator _generator;
    Counter *_counter = nullptr;

public:
    CommonMCData() = default;
    ~CommonMCData();

    double rand(double maxValue);

    void makeCounter(uint reactionsNum);
    Counter *counter() { return _counter; }

private:
    CommonMCData(const CommonMCData &) = delete;
    CommonMCData(CommonMCData &&) = delete;
    CommonMCData &operator = (const CommonMCData &) = delete;
    CommonMCData &operator = (CommonMCData &&) = delete;
};

}

#endif // COMMON_MC_DATA_H
