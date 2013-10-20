#include "multi_events_container.h"

namespace vd
{

MultiEventsContainer::~MultiEventsContainer()
{
    Reaction *prev = 0;
    for (auto &pr : _positions)
    {
        if (pr.first == prev)
        {
            _events[pr.second] = 0;
        }

        prev = pr.first;
    }
}

void MultiEventsContainer::add(Reaction *event, uint n)
{
    for (uint i = 0; i < n; ++i)
    {
        _positions.insert(std::pair<Reaction *, uint>(event, _events.size()));
        _events.push_back(event);
    }
}

void MultiEventsContainer::remove(Reaction *event, uint n)
{
    for (uint i = 0; i < n; ++i)
    {
        auto curr = _positions.find(event);
        assert(curr != _positions.end());

        Reaction *last = removeAndGetLast(curr->second);
        if (last)
        {
            uint lastIndex = _events.size() - 1;
            auto range = _positions.equal_range(last);
            for (auto it = range.first; it != range.second; it++)
            {
                if (it->second == lastIndex)
                {
                    it->second = curr->second;
                    break;
                }
            }
        }

        _positions.erase(curr);
    }
}

}
