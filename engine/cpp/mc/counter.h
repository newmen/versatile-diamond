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
        ullong counter = 0;

        std::string name;
        double rate;

        Record(const std::string &name, double rate) : name(name), rate(rate) {}
        void inc()
        {
#ifdef PARALLEL
#pragma omp atomic
#endif // PARALLEL
            ++counter;
        }
    };

    std::vector<Record *> _records;
    ullong _total = 0;

public:
    Counter(uint reactionsNum);
    ~Counter();

    void inc(Reaction *event);
    ullong total() const { return _total; }

    void printStats();

private:
    void sort();
};

}

#endif // COUNTER_H
