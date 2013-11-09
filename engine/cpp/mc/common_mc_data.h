#ifndef COMMON_MC_DATA_H
#define COMMON_MC_DATA_H

#include "../atoms/atom.h"
#include "../reactions/reaction.h"

#ifndef MIN_DISTANCE
#define MIN_DISTANCE 5
#endif // MIN_DISTANCE

namespace vd
{

class CommonMCData
{
    bool _wasntFound, _sameSite;
    bool _sames[THREADS_NUM];
    Reaction *_reactions[THREADS_NUM];

public:
    CommonMCData();

    void noEvent() { _wasntFound = true; }
    bool wasntFound() const { return _wasntFound; }
    bool hasSameSite() const { return _sameSite; }

    bool isSame();
    void checkSame(Reaction *reaction);

    void reset();

private:
    inline void updateSame(int currentThread, int anotherThread);

    bool isNear(Atom *a, Atom *b) const;
    inline bool isNearByOneAxis(uint max, int v, int w) const;
};

}

#endif // COMMON_MC_DATA_H
