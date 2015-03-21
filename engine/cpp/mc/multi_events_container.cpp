#include "multi_events_container.h"

namespace vd
{

MultiEventsContainer::~MultiEventsContainer()
{
    Atom *prev = nullptr;
    for (auto &pr : _positions)
    {
        if (pr.first == prev)
        {
            _events[pr.second] = nullptr;
        }

        prev = pr.first;
    }

    for (Reaction *event : _events)
    {
        delete event;
    }
}

#ifndef NDEBUG
Reaction *MultiEventsContainer::selectEventByCoords(const int3 &crd)
{
    for (Reaction *event : _events)
    {
        UbiquitousReaction *ubiqEvent = static_cast<UbiquitousReaction *>(event);
        if (ubiqEvent->target()->lattice() && ubiqEvent->target()->lattice()->coords() == crd)
        {
            return event;
        }
    }

    assert(false); // multi event by crd was not found
    return nullptr;
}
#endif // NDEBUG

void MultiEventsContainer::add(UbiquitousReaction *event, ushort n)
{
    for (uint i = 0; i < n; ++i)
    {
        _positions.insert(std::pair<Atom *, uint>(event->target(), _events.size()));
        _events.push_back(event);
    }
}

void MultiEventsContainer::remove(Atom *target, ushort n)
{
#ifndef NDEBUG
    auto range = _positions.equal_range(target);
    assert(std::distance(range.first, range.second) >= n);
#endif // NDEBUG

    unlockedRemove(target, n);
}

uint MultiEventsContainer::removeAll(Atom *target)
{
    auto range = _positions.equal_range(target);
    uint n = std::distance(range.first, range.second);
    unlockedRemove(target, n);
    return n;
}

bool MultiEventsContainer::check(Atom *target)
{
    return _positions.find(target) != _positions.cend();
}

void MultiEventsContainer::unlockedRemove(Atom *target, uint n)
{
    for (uint i = 0; i < n; ++i)
    {
        auto currIt = _positions.find(target);
        assert(currIt != _positions.cend());

        Reaction *current = _events[currIt->second];

        UbiquitousReaction *last = exchangeToLast<UbiquitousReaction>(currIt->second);
        if (last)
        {
            uint lastIndex = _events.size();
            auto range = _positions.equal_range(last->target());

#ifndef NDEBUG
            bool found = false;
#endif // NDEBUG
            for (auto it = range.first; it != range.second; it++)
            {
                if (it->second == lastIndex)
                {
                    it->second = currIt->second;
#ifndef NDEBUG
                    found = true;
#endif // NDEBUG
                    break;
                }
            }

#ifndef NDEBUG
            assert(found);
#endif // NDEBUG
        }

        _positions.erase(currIt);

        auto range = _positions.equal_range(target);
        bool haveSame = false;
        for (auto it = range.first; it != range.second; it++)
        {
            if (_events[it->second] == current)
            {
                haveSame = true;
                break;
            }
        }

        if (!haveSame)
        {
            delete current;
        }
    }

    assert(_events.size() == _positions.size());
}

}
