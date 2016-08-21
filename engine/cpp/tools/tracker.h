#ifndef TRACKER_H
#define TRACKER_H

#include <vector>
#include "../phases/reactor.h"
#include "counters/custom_counter.h"
#include "worker/soul.h"

namespace vd
{

template <class HB>
class Tracker
{
    std::vector<TimeCounter *> _counters;

public:
    Tracker() = default;
    ~Tracker();

    template <class Saver, class... Args>
    void add(double step, Args... args);

    Job *firstFrame(const Reactor<HB> *reactor);
    Job *nextFrame(const Reactor<HB> *reactor);
    void appendTime(double timeDelta);

private:
    Tracker(const Tracker &) = delete;
    Tracker(Tracker &&) = delete;
    Tracker &operator = (const Tracker &) = delete;
    Tracker &operator = (Tracker &&) = delete;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class HB>
Tracker<HB>::~Tracker()
{
    for (TimeCounter *counter : _counters)
    {
        delete counter;
    }
}

template <class HB>
template <class Saver, class... Args>
void Tracker<HB>::add(double step, Args... args)
{
    _counters.push_back(new CustomCounter<Saver>(step, args...));
}

template <class HB>
Job *Tracker<HB>::firstFrame(const Reactor<HB> *reactor)
{
    Job *item = new Soul<HB>(reactor);
    for (TimeCounter *counter : _counters)
    {
        item = counter->init(item);
    }
    return item;
}

template <class HB>
Job *Tracker<HB>::nextFrame(const Reactor<HB> *reactor)
{
    Job *item = new Soul<HB>(reactor);
    for (TimeCounter *counter : _counters)
    {
        item = counter->wrap(item);
    }
    return item;
}

template <class HB>
void Tracker<HB>::appendTime(double timeDelta)
{
    for (TimeCounter *counter : _counters)
    {
        counter->appendTime(timeDelta);
    }
}

}

#endif // TRACKER_H
