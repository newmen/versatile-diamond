#ifndef BASE_MC_DATA_H
#define BASE_MC_DATA_H

#include "events_counter.h"

namespace vd
{

class BaseMCData
{
    EventsCounter *_counter = nullptr;

public:
    virtual ~BaseMCData();

    virtual double rand(double maxValue) = 0;

    void makeCounter(uint reactionsNum);
    EventsCounter *counter() const { return _counter; }

protected:
    BaseMCData() = default;

private:
    BaseMCData(const BaseMCData &) = delete;
    BaseMCData(BaseMCData &&) = delete;
    BaseMCData &operator = (const BaseMCData &) = delete;
    BaseMCData &operator = (BaseMCData &&) = delete;
};

}

#endif // BASE_MC_DATA_H
