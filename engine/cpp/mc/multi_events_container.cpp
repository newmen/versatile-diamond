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
#ifdef PARALLEL
    lock([this, event, n]() {
#endif // PARALLEL

        for (uint i = 0; i < n; ++i)
        {
            _positions.insert(std::pair<Atom *, uint>(event->target(), _events.size()));
            _events.push_back(event);
        }

#ifdef PARALLEL
    });
#endif // PARALLEL
}

void MultiEventsContainer::remove(Atom *target, uint n)
{
#ifdef PARALLEL
    lock([this, target, n]() {
#endif // PARALLEL

        auto range = _positions.equal_range(target);
        assert(std::distance(range.first, range.second) >= n);

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

#ifdef PARALLEL
    });
#endif // PARALLEL
}

uint MultiEventsContainer::check(Atom *target)
{
    uint quantity = 0;

#ifdef PARALLEL
    lock([this, target, &quantity]() {
#endif // PARALLEL

        auto range = _positions.equal_range(target);
        quantity = std::distance(range.first, range.second);

#ifdef PARALLEL
    });
#endif // PARALLEL

    assert(quantity < target->valence());
    return quantity;
}

}
