#include "counter.h"
#include <algorithm>
#include <ostream>

namespace vd
{

Counter::Counter(uint reactionsNum) : _records(reactionsNum, nullptr)
{
}

Counter::~Counter()
{
    for (Record *record : _records)
    {
        delete record;
    }
}

void Counter::inc(Reaction *event)
{
    uint index = event->type();
    assert(_records.size() > index);

#ifdef PARALLEL
#pragma omp critical
#endif // PARALLEL
    {
        if (!_records[index])
        {
            _records[index] = new Record(event->name(), event->rate());
        }

    }

    _records[index]->inc();

#ifdef PARALLEL
#pragma omp atomic
#endif // PARALLEL
    ++_total;
}

void Counter::printStats(std::ostream &os) const
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
