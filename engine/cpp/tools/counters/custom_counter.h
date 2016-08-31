#ifndef CUSTOM_COUNTER_H
#define CUSTOM_COUNTER_H

#include "../worker/frame.h"
#include "time_counter.h"

namespace vd
{

template <class Saver>
class CustomCounter : public TimeCounter
{
    Saver _saver;

public:
    template <class... Args> CustomCounter(double step, Args... args) :
        TimeCounter(step), _saver(args...) {}

    Job *init(Job *item) override;

protected:
    Job *wrappedItem(Job *item) override;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class S>
Job *CustomCounter<S>::init(Job *item)
{
    if (_saver.needToInit())
    {
        return wrappedItem(item);
    }
    else
    {
        return item;
    }
}

template <class S>
Job *CustomCounter<S>::wrappedItem(Job *item)
{
    return new Frame(item, &_saver);
}

}

#endif // CUSTOM_COUNTER_H
