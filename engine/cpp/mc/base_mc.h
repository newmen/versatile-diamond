#ifndef BASE_MC_H
#define BASE_MC_H

#include <limits>
#include "../reactions/spec_reaction.h"
#include "../reactions/ubiquitous_reaction.h"
#include "base_mc_data.h"

#define DISABLE_MC_SORT false

namespace vd
{

class BaseMC
{
    double _totalTime = 0.0;

public:
    virtual ~BaseMC() {}

    double totalTime() const { return _totalTime; }
    void initCounter(BaseMCData *data) const;

    virtual void sort() = 0;
    virtual void halfSort() = 0;

    double doRandom(BaseMCData *data);
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

    virtual uint totalEventsNum() const = 0;
    virtual Reaction *mostProbablyEvent(double r) = 0;
    virtual void recountTotalRate() = 0;

    double increaseTime(BaseMCData *data);

#if defined(PRINT) || defined(MC_PRINT)
    void printReaction(Reaction *reaction, std::string action, std::string type, uint n = 1);
#endif // PRINT || MC_PRINT

private:
    BaseMC(const BaseMC &) = delete;
    BaseMC(BaseMC &&) = delete;
    BaseMC &operator = (const BaseMC &) = delete;
    BaseMC &operator = (BaseMC &&) = delete;
};

}

#endif // BASE_MC_H
