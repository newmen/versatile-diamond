#ifndef SCAVENGER_H
#define SCAVENGER_H

#include "../atoms/atom.h"
#include "../species/base_spec.h"
#include "../reactions/spec_reaction.h"
#include "../reactions/ubiquitous_reaction.h"
#include "collector.h"

namespace vd
{

class Scavenger
        : protected Collector<Atom>
        , protected Collector<BaseSpec>
        , protected Collector<SpecReaction>
        , protected Collector<UbiquitousReaction>
{
    typedef Collector<Atom> AtomsCollector;
    typedef Collector<BaseSpec> SpecsCollector;
    typedef Collector<SpecReaction> SpecReactionsCollector;
    typedef Collector<UbiquitousReaction> UbiquitousReactionsCollector;

public:
    ~Scavenger();

    void markAtom(Atom *atom);
    void markSpec(BaseSpec *spec);
    void markReaction(SpecReaction *reaction);
    void markReaction(UbiquitousReaction *reaction);

    void clear();

private:
    template <class T> void deleteAndClear();
};

//////////////////////////////////////////////////////////////////////////////////////

template <class T>
void Scavenger::deleteAndClear()
{
    Collector<T>::each([](T *item) {
        delete item;
    });

    Collector<T>::clear();
}

}

#endif // SCAVENGER_H
