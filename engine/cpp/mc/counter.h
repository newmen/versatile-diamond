#ifndef COUNTER_H
#define COUNTER_H

#include <string>
#include <vector>
#include "../reactions/reaction.h"

namespace vd
{

class Counter
{
    struct Record
    {
        uint counter = 0;

        std::string name;
        double rate = 0;

        Record(const std::string &name, double rate) : name(name), rate(rate) {}
        void inc() { ++counter; }
    };

    std::vector<Record *> _records;
    uint _total = 0;

public:
    Counter(uint reactionsNum);
    ~Counter();

    void inc(Reaction *event);
    uint total() const { return _total; }

    void printStats();

private:
    void sort();
};

}

#endif // COUNTER_H
