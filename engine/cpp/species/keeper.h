#ifndef KEEPER_H
#define KEEPER_H

#include <vector>
#include "../tools/collector.h"

namespace vd
{

template <class S>
class Keeper : public Collector<S>
{
public:
    void findReactions();
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class S>
void Keeper<S>::findReactions()
{
    Collector<S>::each([](S * spec) {
        spec->findReactions();
    });
}

}

#endif // KEEPER_H
