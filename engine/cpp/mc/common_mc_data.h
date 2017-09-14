#ifndef COMMON_MC_DATA_H
#define COMMON_MC_DATA_H

#include "base_mc_data.h"
#include "random_generator.h"

namespace vd
{

class CommonMCData : public BaseMCData
{
private:
    RandomGenerator _generator;

public:
    CommonMCData() = default;

    double rand(double maxValue) override
    {
        return _generator.rand(maxValue);
    }
};

}

#endif // COMMON_MC_DATA_H
