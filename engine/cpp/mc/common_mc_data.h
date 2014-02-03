#ifndef COMMON_MC_DATA_H
#define COMMON_MC_DATA_H

#include "../atoms/atom.h"
#include "../reactions/reaction.h"
#include "counter.h"
#include "random_generator.h"

#ifndef MIN_DISTANCE
#define MIN_DISTANCE 8
#endif // MIN_DISTANCE

namespace vd
{

class CommonMCData
{
    RandomGenerator _generators[THREADS_NUM];

    ushort _wasntFound, _sameSites;
    bool _sames[THREADS_NUM];
    Reaction *_reactions[THREADS_NUM];

    Counter *_counter = nullptr;

public:
    CommonMCData();
    ~CommonMCData();

    double rand(double maxValue);

    void makeCounter(uint reactionsNum);
    Counter *counter() { return _counter; }

    void setEventNotFound();
    bool eventWasntFound() const { return _wasntFound > 0; }
    bool hasSameSite() const { return _sameSites > 0; }

    void store(Reaction *reaction);
    void checkSame();
    bool isSame();

    void reset();

private:
    CommonMCData(const CommonMCData &) = delete;
    CommonMCData(CommonMCData &&) = delete;
    CommonMCData &operator = (const CommonMCData &) = delete;
    CommonMCData &operator = (CommonMCData &&) = delete;

    inline int currThreadNum() const;
    inline void updateSame(int currentThread, int anotherThread);
    inline void setSame(uint threadId);

    bool isNear(Atom *a, Atom *b) const;
    bool isNearByCrystal(Atom *a, Atom *b) const;
    inline bool isNearByOneAxis(uint max, int v, int w) const;
};

}

#endif // COMMON_MC_DATA_H
