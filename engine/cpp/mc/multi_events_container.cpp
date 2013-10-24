#include "multi_events_container.h"

//#include <iostream>
//using namespace std;

namespace vd
{

MultiEventsContainer::~MultiEventsContainer()
{
//    cout << _positions.size() << endl;

    Atom *prev = 0;
    for (auto &pr : _positions)
    {
//        cout << pr.second << " -> " << pr.first;
        if (pr.first == prev)
        {
            _events[pr.second] = 0;
//            cout << " :: zerofied";
        }
//        cout << endl;

        prev = pr.first;
    }

    for (Reaction *event : _events)
    {
        delete event;
    }
}

void MultiEventsContainer::add(MultiReaction *event, uint n)
{
    for (uint i = 0; i < n; ++i)
    {
        _positions.insert(std::pair<Atom *, uint>(event->target(), _events.size()));
        _events.push_back(event);
    }
}

void MultiEventsContainer::remove(MultiReaction *event, uint n)
{
    Atom *anchor = event->target();

    for (uint i = 0; i < n; ++i)
    {
        auto curr = _positions.find(anchor);
        assert(curr != _positions.end());

        Reaction *current = *(_events.begin() + curr->second);

        MultiReaction *last = static_cast<MultiReaction *>(exchangeToLast(curr->second));
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

        curr = _positions.find(anchor);
        if (curr == _positions.end())
        {
            delete current;
        }
    }

    assert(_events.size() == _positions.size());
}

}
