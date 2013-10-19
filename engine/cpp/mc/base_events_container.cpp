#include "base_events_container.h"

#include <iostream>

namespace vd
{

BaseEventsContainer::~BaseEventsContainer()
{
    std::cout << _events.size() << std::endl;
//    for (Reaction *event : _events)
    for (uint i = 0; i < _events.size(); ++i)
    {
//        std::cout << i << " " << _events[i]->rate() << std::endl;
//        std::cout << event->rate() << std::endl;
//        delete event;
//        delete _events[i];
    }
}

double BaseEventsContainer::commonRate() const
{
    return (_events.size() > 0) ?
                _events.front()->rate() * _events.size() :
                0.0;
}

}
