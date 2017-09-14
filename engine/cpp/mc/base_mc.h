#ifndef BASE_MC_H
#define BASE_MC_H

#include <limits>
#include "../reactions/spec_reaction.h"
#include "../reactions/ubiquitous_reaction.h"

namespace vd
{

template <class MCData, ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
class BaseMC
{
    double _totalTime = 0.0;

public:
    virtual ~BaseMC() {}

    double totalTime() const { return _totalTime; }
    void initCounter(MCData *data) const;

    virtual void sort() = 0;

    virtual double doRandom(MCData *data);
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

    double increaseTime(MCData *data);

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

template <class MCData, ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void BaseMC<MCData, EVENTS_NUM, MULTI_EVENTS_NUM>::initCounter(MCData *data) const
{
    data->makeCounter(EVENTS_NUM + MULTI_EVENTS_NUM);
}

template <class MCData, ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
double BaseMC<MCData, EVENTS_NUM, MULTI_EVENTS_NUM>::doRandom(MCData *data)
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

        if (totalRate() == 0)
        {
            return -1;
        }
        else
        {
            sort();
            return doRandom(data);
        }
    }
}

template <class MCData, ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
double BaseMC<MCData, EVENTS_NUM, MULTI_EVENTS_NUM>::increaseTime(MCData *data)
{
    static double min = std::numeric_limits<double>::denorm_min();
    double r = data->rand(1.0) + min;
    double dt = -log(r) / totalRate();
    _totalTime += dt;

    return dt;
}

#if defined(PRINT) || defined(MC_PRINT)
template <class MCData, ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void MC<MCData, EVENTS_NUM, MULTI_EVENTS_NUM>::printReaction(
        Reaction *reaction, std::string action, std::string type, uint n
)
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
