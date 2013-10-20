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

    double commonRate() const;

protected:
    Reaction *removeAndGetLast(uint index);

    std::vector<Reaction *> _events;
};

}

#endif // BASE_EVENTS_CONTAINER_H
