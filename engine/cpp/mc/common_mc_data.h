#ifndef COMMON_MC_DATA_H
#define COMMON_MC_DATA_H

#include "../atoms/atom.h"
#include "../reactions/reaction.h"
#include "counter.h"

#ifndef MIN_DISTANCE
#define MIN_DISTANCE 10
#endif // MIN_DISTANCE

namespace vd
{

class CommonMCData
{
    bool _wasntFound, _sameSite;
    bool _sames[THREADS_NUM];
    Reaction *_reactions[THREADS_NUM];

    Counter *_counter = nullptr;

public:
    CommonMCData();
    ~CommonMCData();

    void makeCounter(uint reactionsNum);
    Counter *counter() { return _counter; }

    void setEventNotFound() { _wasntFound = true; }
    bool eventWasntFound() const { return _wasntFound; }
    bool hasSameSite() const { return _sameSite; }

    void store(Reaction *reaction);
    void checkSame();
    bool isSame();

    void reset();

private:
    inline int currThreadNum() const;
    inline void updateSame(int currentThread, int anotherThread);

    bool isNear(Atom *a, Atom *b) const;
    inline bool isNearByOneAxis(uint max, int v, int w) const;
};

}

#endif // COMMON_MC_DATA_H
