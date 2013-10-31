#ifndef SCAVENGER_H
#define SCAVENGER_H

#include "../species/specific_spec.h"
#include "../reactions/spec_reaction.h"
#include "collector.h"

namespace vd
{

template <ushort SPECS_NUM, ushort DUAL_TYPICAL_REACTIONS_NUM>
class Scavenger
        : protected Collector<BaseSpec, SPECS_NUM>
        , protected Collector<SpecReaction, DUAL_TYPICAL_REACTIONS_NUM>
{
public:
    ~Scavenger();

    template <ushort ID> void storeReaction(SpecReaction *reaction);
    template <ushort ID> void storeSpec(BaseSpec *spec);

    void clear();

private:
    template <class T, ushort NUM> void deleteAndClear();
};

template <ushort SPECS_NUM, ushort DUAL_TYPICAL_REACTIONS_NUM>
template <ushort ID>
void Scavenger<SPECS_NUM, DUAL_TYPICAL_REACTIONS_NUM>::storeReaction(SpecReaction *reaction)
{
    Collector<SpecReaction, DUAL_TYPICAL_REACTIONS_NUM>::template store<ID>(reaction);
}

template <ushort SPECS_NUM, ushort DUAL_TYPICAL_REACTIONS_NUM>
template <ushort ID>
void Scavenger<SPECS_NUM, DUAL_TYPICAL_REACTIONS_NUM>::storeSpec(BaseSpec *spec)
{
    Collector<BaseSpec, SPECS_NUM>::template store<ID>(spec);
}

template <ushort SPECS_NUM, ushort DUAL_TYPICAL_REACTIONS_NUM>
Scavenger<SPECS_NUM, DUAL_TYPICAL_REACTIONS_NUM>::~Scavenger()
{
    clear();
}

template <ushort SPECS_NUM, ushort DUAL_TYPICAL_REACTIONS_NUM>
void Scavenger<SPECS_NUM, DUAL_TYPICAL_REACTIONS_NUM>::clear()
{
    deleteAndClear<BaseSpec, SPECS_NUM>();
    deleteAndClear<SpecReaction, DUAL_TYPICAL_REACTIONS_NUM>();
}

template <ushort SPECS_NUM, ushort DUAL_TYPICAL_REACTIONS_NUM>
template <class T, ushort NUM>
void Scavenger<SPECS_NUM, DUAL_TYPICAL_REACTIONS_NUM>::deleteAndClear()
{
    Collector<T, NUM>::each([](std::vector<T *> &items) {
        for (T *item : items)
        {
            delete item;
        }
    });

    Collector<T, NUM>::clear();
}

}

#endif // SCAVENGER_H
