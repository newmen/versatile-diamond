#include "base_events_container.h"

#ifdef PRINT
#include <iostream>
#endif // PRINT

namespace vd
{

BaseEventsContainer::~BaseEventsContainer()
{
}

void BaseEventsContainer::doEvent(double r)
{
    assert(_events.size() > 0);

    uint index = (uint)(r / _events.front()->rate());
    assert(index < _events.size());

#ifdef PRINT
    std::cout << "SELECTED: " << index << std::endl;
#endif // PRINT

    _events[index]->doIt();
}

double BaseEventsContainer::commonRate() const
{
    return (_events.size() > 0) ?
                _events.front()->rate() * _events.size() :
                0.0;
}

Reaction *BaseEventsContainer::exchangeToLast(uint index)
{
    assert(index < _events.size());

    Reaction *last = _events.back();
    _events.pop_back();

    if (_events.begin() + index == _events.end())
    {
        return nullptr;
    }
    else
    {
        _events[index] = last;
        return last;
    }
}

}
