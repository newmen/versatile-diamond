#ifndef BASE_EVENTS_CONTAINER_H
#define BASE_EVENTS_CONTAINER_H

#include <vector>
#include "../reaction.h"

namespace vd
{

class BaseEventsContainer
{
public:
    virtual ~BaseEventsContainer();

    void doEvent(double r);
    double commonRate() const;

protected:
    Reaction *exchangeToLast(uint index);

    std::vector<Reaction *> _events;
};

}

#endif // BASE_EVENTS_CONTAINER_H
