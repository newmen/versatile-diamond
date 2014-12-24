#ifndef KEEPER_H
#define KEEPER_H

#include "../tools/collector.h"

namespace vd
{

template <class S, void (S::*M)()>
class Keeper : public Collector<S>
{
public:
    void find();
};

//////////////////////////////////////////////////////////////////////////////////////

template <class S, void (S::*M)()>
void Keeper<S, M>::find()
{
    Collector<S>::each([](S *spec) {
        (spec->*M)();
    });
}

}

#endif // KEEPER_H
