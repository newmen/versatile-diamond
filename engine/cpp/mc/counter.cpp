#include "counter.h"
#include <iostream>
#include <algorithm>

#ifdef PARALLEL
#include <omp.h>
#endif // PARALLEL

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

        _records[index]->inc();
        ++_total;
    }
}

void Counter::printStats()
{
    sort();

    std::cout << "Total events: " << _total << "\n";
    for (Record *record : _records)
    {
        if (!record) continue;

        std::cout.width(74);
        std::cout << record->name << " :: ";

        std::cout.width(11);
        std::cout << record->counter << " :: ";

        double rate = 100 * (double)record->counter / _total;
        std::cout.width(11);
        std::cout.precision(3);
        std::cout << rate << " % :: ";
        std::cout << record->rate << std::endl;
    }
}

void Counter::sort()
{
    auto compare = [](Record *a, Record *b) {
        return !a || !b || a->counter > b->counter;
    };

    std::sort(_records.begin(), _records.end(), compare);
}

}
