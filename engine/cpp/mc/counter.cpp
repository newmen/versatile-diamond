#include "counter.h"
#include <ostream>
#include <algorithm>

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

void Counter::printStats(std::ostream &os)
{
    sort();

    os.precision(3);
    os << "Total events: " << _total << "\n";
    for (Record *record : _records)
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

void Counter::sort()
{
    std::sort(_records.begin(), _records.end(), [](Record *a, Record *b) {
        if (a == nullptr)
        {
            return b == nullptr;
        }
        else if (b == nullptr)
        {
            return false;
        }
        else
        {
            return a->counter > b->counter;
        }
    });
}

}
