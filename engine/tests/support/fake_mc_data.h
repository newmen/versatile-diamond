#ifndef FAKE_MC_DATA_H
#define FAKE_MC_DATA_H

// #include <iostream>
#include <mc/base_mc_data.h>

class FakeMCData : public BaseMCData
{
private:
    uint _counter = 0;
    double _value = -1;

public:
    FakeMCData() = default;

    void set(double value)
    {
        _value = value;
    }

    double rand(double maxValue) override
    {
        // std::cout << "Max: " << maxValue << " | Current: " << _value << std::endl;
        return (_counter++ % 2 == 0) ? _value : 0.5;
    }
};

#endif // FAKE_MC_DATA_H
