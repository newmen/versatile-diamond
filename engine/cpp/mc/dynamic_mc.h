#ifndef MC_H
#define MC_H

//#include <parallel/algorithm> // __gnu_parallel::sort
#include <algorithm> // std::sort
#include <cmath>
#include <functional>
#include <vector>
#include "../tools/json_steps_logger.h"
#include "events/events_container.h"
#include "events/multi_events_container.h"
#include "base_mc.h"

namespace vd
{

class DynamicMC : public BaseMC
{
    enum : ushort { MULTI_EVENTS_INDEX_SHIFT = 1000 }; // for #compareContainers()

    double _totalRate = 0;

    std::vector<EventsContainer> _events;
    std::vector<MultiEventsContainer> _multiEvents;
    std::vector<uint> _order;

public:
    DynamicMC(ushort eventsNum, ushort multiEventsNum);

    void sort() final;
    void halfSort() final;

#ifdef JSONLOG
    JSONStepsLogger::Dict counts();
#endif // JSONLOG

    double totalRate() const { return _totalRate; }

    void add(ushort index, SpecReaction *reaction) final;
    void remove(ushort index, SpecReaction *reaction) final;

    void add(ushort index, UbiquitousReaction *reaction, ushort n) final;
    void remove(ushort index, UbiquitousReaction *templateReaction, ushort n) final;
    void removeAll(ushort index, UbiquitousReaction *templateReaction) final;
    bool check(ushort index, Atom *target) final;

#ifndef NDEBUG
    void doOneOfOne(ushort rt);
    void doLastOfOne(ushort rt);

    void doOneOfMul(ushort rt);
    void doOneOfMul(ushort rt, int x, int y, int z);
    void doLastOfMul(ushort rt);
#endif // NDEBUG

protected:
    uint totalEventsNum() const final;
    Reaction *mostProbablyEvent(double r) final;
    void recountTotalRate();

private:
    DynamicMC(const DynamicMC &) = delete;
    DynamicMC(DynamicMC &&) = delete;
    DynamicMC &operator = (const DynamicMC &) = delete;
    DynamicMC &operator = (DynamicMC &&) = delete;

    void updateRate(double r)
    {
        _totalRate += r;
    }

    inline BaseEventsContainer *events(uint orderIndex);
    inline BaseEventsContainer *correspondEvents(uint orderValue);
};

}

#endif // MC_H
