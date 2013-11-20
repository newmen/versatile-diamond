#ifndef COUNTER_H
#define COUNTER_H

#include <iostream>
#include <string>
#include <unordered_map>
#include "../reactions/reaction.h"

namespace vd
{

class Counter
{
    std::unordered_map<uint, std::string> _names;
    std::unordered_map<uint, uint> _counter;
    uint _total = 0;

public:
    void inc(Reaction *event)
    {
        uint key = event->type();

#ifdef PARALLEL
#pragma omp critical
#endif // PARALLEL
        {
            if (_counter.find(key) == _counter.cend())
            {
                _counter[key] = 0;
                _names[key] = event->name();
            }

            ++_counter[key];
            ++_total;
        }
    }

    void printStats()
    {
        std::cout << "Total events: " << _total << "\n";
        for (auto &pr : _counter)
        {
            std::cout.width(74);
            std::cout << _names[pr.first] << " :: ";

            double rate = (double)pr.second / _total;
            std::cout.width(11);
            std::cout << pr.second << " :: ";
            std::cout.precision(2);
            std::cout << rate << " %" << std::endl;
        }
    }
};

}

#endif // COUNTER_H
