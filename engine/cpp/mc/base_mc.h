#ifndef BASE_MC_H
#define BASE_MC_H

#include "../reactions/spec_reaction.h"
#include "../reactions/ubiquitous_reaction.h"
#include "common_mc_data.h"

namespace vd
{

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
class BaseMC
{
    double _totalTime = 0.0;

public:
    virtual ~BaseMC() {}

    double totalTime() const { return _totalTime; }
    void initCounter(CommonMCData *data) const;

    virtual void sort() = 0;

    virtual double doRandom(CommonMCData *data);
    virtual double totalRate() const  = 0;

    virtual void add(ushort index, SpecReaction *reaction) = 0;
    virtual void remove(ushort index, SpecReaction *reaction) = 0;

    virtual void add(ushort index, UbiquitousReaction *reaction, ushort n) = 0;
    virtual void remove(ushort index, UbiquitousReaction *reaction, ushort n) = 0;
    virtual void removeAll(ushort index, UbiquitousReaction *reaction) = 0;
    virtual bool check(ushort index, Atom *target) = 0;

#ifndef NDEBUG
    virtual void doOneOfOne(ushort rt) = 0;
    virtual void doLastOfOne(ushort rt) = 0;

    virtual void doOneOfMul(ushort rt) = 0;
    virtual void doOneOfMul(ushort rt, int x, int y, int z) = 0;
    virtual void doLastOfMul(ushort rt) = 0;
#endif // NDEBUG

protected:
    BaseMC() = default;

    virtual Reaction *mostProbablyEvent(double r) = 0;
    virtual void recountTotalRate() = 0;

    double increaseTime(CommonMCData *data);

#if defined(PRINT) || defined(MC_PRINT)
    void printReaction(Reaction *reaction, std::string action, std::string type, uint n = 1);
#endif // PRINT || MC_PRINT

private:
    BaseMC(const BaseMC &) = delete;
    BaseMC(BaseMC &&) = delete;
    BaseMC &operator = (const BaseMC &) = delete;
    BaseMC &operator = (BaseMC &&) = delete;
};

//////////////////////////////////////////////////////////////////////////////////////

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void BaseMC<EVENTS_NUM, MULTI_EVENTS_NUM>::initCounter(CommonMCData *data) const
{
    data->makeCounter(EVENTS_NUM + MULTI_EVENTS_NUM);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
double BaseMC<EVENTS_NUM, MULTI_EVENTS_NUM>::doRandom(CommonMCData *data)
{
    double r = data->rand(totalRate());
    Reaction *event = mostProbablyEvent(r);
    if (event)
    {
#if defined(PRINT) || defined(MC_PRINT)
        debugPrint([&](IndentStream &os) {
            os << event->name();
        });
#endif // PRINT || MC_PRINT

        data->counter()->inc(event);
        event->doIt();
        return increaseTime(data);
    }
    else
    {
#if defined(PRINT) || defined(MC_PRINT)
        debugPrint([&](IndentStream &os) {
            os << "Event not found! Recount and sort!";
        });
#endif // PRINT || MC_PRINT

        recountTotalRate();
        sort();

        if (totalRate() == 0)
        {
            return -1;
        }
        else
        {
            return doRandom(data);
        }
    }
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
double BaseMC<EVENTS_NUM, MULTI_EVENTS_NUM>::increaseTime(CommonMCData *data)
{
    double r = data->rand(1.0);
    double dt = -log(r) / totalRate();
    _totalTime += dt;

    return dt;
}

#if defined(PRINT) || defined(MC_PRINT)
template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::printReaction(Reaction *reaction, std::string action, std::string type, uint n)
{
    debugPrint([&](IndentStream &os) {
        os << "MC::printReaction() ";
        os << action << " ";
        if (n > 1)
        {
            os << n << " ";
        }
        os << type << " (" << reaction->type() << ") ";
        reaction->info(os);
    });
}
#endif // PRINT || MC_PRINT

}

#endif // BASE_MC_H
