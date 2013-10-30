#ifndef BASE_EVENTS_CONTAINER_H
#define BASE_EVENTS_CONTAINER_H

#include <vector>
#include <unordered_map>
#include "../reactions/reaction.h"

namespace vd
{

class BaseEventsContainer
{
public:
    virtual ~BaseEventsContainer();

    void doEvent(double r);
    double commonRate() const;

#ifdef PRINT
    uint size() const { return _events.size(); }
#endif // PRINT

protected:
    Reaction *exchangeToLast(uint index);

    std::vector<Reaction *> _events;
};

}

#endif // BASE_EVENTS_CONTAINER_H
