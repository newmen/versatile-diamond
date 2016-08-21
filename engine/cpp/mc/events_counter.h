#ifndef COUNTER_H
#define COUNTER_H

#include <vector>
#include "../reactions/reaction.h"

namespace vd
{

class EventsCounter
{
    struct Record
    {
        ullong counter = 0;

        const char *name;
        double rate;

        Record(const char *name, double rate) : name(name), rate(rate) {}
        void inc() { ++counter; }

    private:
        Record(const Record &) = delete;
        Record(Record &&) = delete;
        Record &operator = (const Record &) = delete;
        Record &operator = (Record &&) = delete;
    };

    std::vector<Record *> _records;
    ullong _total = 0;

public:
    EventsCounter(uint reactionsNum);
    ~EventsCounter();

    void inc(Reaction *event);
    ullong total() const { return _total; }

    void printStats(std::ostream &os) const;

private:
    EventsCounter(const EventsCounter &) = delete;
    EventsCounter(EventsCounter &&) = delete;
    EventsCounter &operator = (const EventsCounter &) = delete;
    EventsCounter &operator = (EventsCounter &&) = delete;
};

}

#endif // COUNTER_H
