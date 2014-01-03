#ifndef REACTANTS_KEEPER_H
#define REACTANTS_KEEPER_H

#include "../tools/collector.h"

namespace vd
{

template <class S>
class ReactantsKeeper : public Collector<S>
{
public:
    void findReactions();
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class S>
void ReactantsKeeper<S>::findReactions()
{
    Collector<S>::each([](S * spec) {
        spec->findReactions();
    });
}

}

#endif // REACTANTS_KEEPER_H
