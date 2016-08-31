#ifndef TIME_COUNTER_H
#define TIME_COUNTER_H

#include "../../tools/worker/job.h"

namespace vd
{

class TimeCounter
{
    double _elapsedTime = 0;
    double _step;

public:
    TimeCounter(double step) : _step(step) {}
    virtual ~TimeCounter() {}

    virtual Job *init(Job *item) = 0;

    Job *wrap(Job *item);

    void appendTime(double timeDelta) { _elapsedTime += timeDelta; }

protected:
    virtual Job *wrappedItem(Job *item) = 0;

private:
    TimeCounter(const TimeCounter &) = delete;
    TimeCounter(TimeCounter &&) = delete;
    TimeCounter &operator = (const TimeCounter &) = delete;
    TimeCounter &operator = (TimeCounter &&) = delete;
};

}

#endif // TIME_COUNTER_H
