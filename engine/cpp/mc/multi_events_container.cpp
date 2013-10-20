#include "multi_events_container.h"

#include <iostream>
using namespace std;

namespace vd
{

MultiEventsContainer::~MultiEventsContainer()
{
    cout << _positions.size() << endl;

    Reaction *prev = 0;
    for (auto &pr : _positions)
    {
        cout << pr.second << " -> " << pr.first;
        if (pr.first == prev)
        {
            _events[pr.second] = 0;
            cout << " :: zerofied";
        }
        cout << endl;

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

        Reaction *last = exchangeToLast(curr->second);
        if (last)
        {
            uint lastIndex = _events.size();
            auto range = _positions.equal_range(last);

#ifdef DEBUG
            bool found = false;
#endif // DEBUG
            for (auto it = range.first; it != range.second; it++)
            {
                if (it->second == lastIndex)
                {
                    it->second = curr->second;
#ifdef DEBUG
                    found = true;
#endif // DEBUG
                    break;
                }
            }

            assert(found);
        }

        _positions.erase(curr);

        curr = _positions.find(event);
        if (curr == _positions.end())
        {
            delete event;
        }
    }

    assert(_events.size() == _positions.size());
}

}
