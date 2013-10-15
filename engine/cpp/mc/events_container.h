#ifndef EVENTS_CONTAINER_H
#define EVENTS_CONTAINER_H

#include <unordered_map>
#include <vector>
#include <omp.h>

namespace vd
{

template <class R>
class BaseEventsContainer
{
protected:
    std::vector<R *> _events;

public:
    virtual ~BaseEventsContainer();

protected:
    template <class M>
    inline void remove(M *mirror, std::vector<R *> *events, R *event);
};

template <class R>
BaseEventsContainer<R>::~BaseEventsContainer()
{
    for (R *event : _events) delete event;
}

template <class R>
template <class M>
void BaseEventsContainer<R>::remove(M *mirror, std::vector<R *> *events, R *event)
{
    auto curr = mirror->find(event);
    assert(curr != mirror->end());

    R *last = *events->rbegin();
    events->pop_back();

    auto it = events->begin() + curr->second;
    delete *it;
    *it = last;
    mirror->erase(curr);
}

template <class R>
class EventsContainer : public BaseEventsContainer<R>
{
    std::unordered_map<R *, uint> _mirror;
    std::vector<R *> _events;

public:
    void add(R *event);
    void remove(R *event);
};

template <class R>
void EventsContainer<R>::add(R *event)
{
#pragma omp critical
    {
        assert(_mirror.find(event) == _mirror.end());
        _events.push_back(event);
        _mirror[event] = _events.size() - 1;
    }
}

template <class R>
void EventsContainer<R>::remove(R *event)
{
#pragma omp critical
    {
         BaseEventsContainer<R>::remove(&_mirror, &_events, event);
    }
}

template <class R>
class MultiEventsContainer : public BaseEventsContainer<R>
{
    std::unordered_multimap<R *, uint> _mirror;
    std::vector<R *> _events;

public:
    void add(R *event, uint n);
    void remove(R *event, uint n);
};

template <class R>
void MultiEventsContainer<R>::add(R *event, uint n)
{
#pragma omp critical
    {
        for (int i = 0; i < n; ++i)
        {
            _events.push_back(event);
            _mirror.insert(std::pair<R *, uint>(event, _events.size() - 1));
        }
    }
}

template <class R>
void MultiEventsContainer<R>::remove(R *event, uint n)
{
#pragma omp critical
    {
        for (int i = 0; i < n; ++i)
             BaseEventsContainer<R>::remove(&_mirror, &_events, event);
    }
}

}

#endif // EVENTS_CONTAINER_H
