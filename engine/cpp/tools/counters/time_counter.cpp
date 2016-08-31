#include "time_counter.h"

namespace vd
{

Job *TimeCounter::wrap(Job *item)
{
    if (_elapsedTime < _step)
    {
        return item;
    }
    else
    {
        _elapsedTime -= _step;
        return wrappedItem(item);
    }
}

}
