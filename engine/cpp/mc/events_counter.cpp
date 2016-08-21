#include "events_counter.h"
#include <algorithm>
#include <ostream>

namespace vd
{

EventsCounter::EventsCounter(uint reactionsNum) : _records(reactionsNum, nullptr)
{
}

EventsCounter::~EventsCounter()
{
    for (Record *record : _records)
    {
        delete record;
    }
}

void EventsCounter::inc(Reaction *event)
{
    uint index = event->type();
    assert(_records.size() > index);

    if (!_records[index])
    {
        _records[index] = new Record(event->name(), event->rate());
    }
    _records[index]->inc();
    ++_total;
}

void EventsCounter::printStats(std::ostream &os) const
{
    auto recordsDup = _records;
    auto itEnd = std::remove_if(recordsDup.begin(), recordsDup.end(), [](Record *record) {
        return record == nullptr;
    });

    recordsDup.erase(itEnd, recordsDup.end());
    std::sort(recordsDup.begin(), recordsDup.end(), [](Record *a, Record *b) {
        return a->counter > b->counter;
    });

    os.precision(3);
    os << "Total events: " << _total << "\n";
    for (Record *record : recordsDup)
    {
        if (!record) continue;

        os.width(74);
        os << record->name << " :: ";

        os.width(11);
        os << record->counter << " :: ";

        double rate = 100 * (double)record->counter / _total;
        os.width(11);
        os << rate << " % :: ";
        os << record->rate << std::endl;
    }
}

}
