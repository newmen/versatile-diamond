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

void MultiEventsContainer::add(UbiquitousReaction *event, uint n)
{
    for (uint i = 0; i < n; ++i)
    {
        _positions.insert(std::pair<Atom *, uint>(event->target(), _events.size()));
        _events.push_back(event);
    }
}

void MultiEventsContainer::remove(UbiquitousReaction *event, uint n)
{
    Atom *anchor = event->target();

    for (uint i = 0; i < n; ++i)
    {
        auto currIt = _positions.find(anchor);
        assert(currIt != _positions.end());

        Reaction *current = _events[currIt->second];

        UbiquitousReaction *last = static_cast<UbiquitousReaction *>(exchangeToLast(currIt->second));
        if (last)
        {
            uint lastIndex = _events.size();
            auto range = _positions.equal_range(last->target());

#ifdef DEBUG
            bool found = false;
#endif // DEBUG
            for (auto it = range.first; it != range.second; it++)
            {
                if (it->second == lastIndex)
                {
                    it->second = currIt->second;
#ifdef DEBUG
                    found = true;
#endif // DEBUG
                    break;
                }
            }

#ifdef DEBUG
            assert(found);
#endif // DEBUG
        }

        _positions.erase(currIt);

        auto range = _positions.equal_range(anchor);
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
