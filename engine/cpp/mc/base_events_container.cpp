#include "base_events_container.h"

namespace vd
{

Reaction *BaseEventsContainer::selectEvent(double r)
{
    assert(_events.size() > 0);

    uint index = (uint)(r / _events.front()->rate());
    assert(index < _events.size());

#ifdef PRINT
    debugPrint([&](IndentStream &os) {
        os << "BaseEventsContainer::selectEvent: " << index;
    });
#endif // PRINT

    return _events[index];
}

}
