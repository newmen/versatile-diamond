#ifndef SCAVENGER_H
#define SCAVENGER_H

#include "../atoms/atom.h"
#include "../species/base_spec.h"
#include "../reactions/spec_reaction.h"
#include "collector.h"

namespace vd
{

template <ushort SPECS_NUM, ushort DUAL_TYPICAL_REACTIONS_NUM>
class Scavenger
        : protected Collector<Atom, 1>
        , protected Collector<BaseSpec, SPECS_NUM>
        , protected Collector<SpecReaction, DUAL_TYPICAL_REACTIONS_NUM>
{
public:
    ~Scavenger();

    template <ushort ID> void markReaction(SpecReaction *reaction);
    template <ushort ID> void markSpec(BaseSpec *spec);
    void markAtom(Atom *atom);

    void clear();

private:
    template <class T, ushort NUM> void deleteAndClear();
};

template <ushort SPECS_NUM, ushort DUAL_TYPICAL_REACTIONS_NUM>
Scavenger<SPECS_NUM, DUAL_TYPICAL_REACTIONS_NUM>::~Scavenger()
{
    clear();
}

template <ushort SPECS_NUM, ushort DUAL_TYPICAL_REACTIONS_NUM>
template <ushort ID>
void Scavenger<SPECS_NUM, DUAL_TYPICAL_REACTIONS_NUM>::markReaction(SpecReaction *reaction)
{
    Collector<SpecReaction, DUAL_TYPICAL_REACTIONS_NUM>::template store<ID>(reaction);
}

template <ushort SPECS_NUM, ushort DUAL_TYPICAL_REACTIONS_NUM>
template <ushort ID>
void Scavenger<SPECS_NUM, DUAL_TYPICAL_REACTIONS_NUM>::markSpec(BaseSpec *spec)
{
    Collector<BaseSpec, SPECS_NUM>::template store<ID>(spec);
}

template <ushort SPECS_NUM, ushort DUAL_TYPICAL_REACTIONS_NUM>
void Scavenger<SPECS_NUM, DUAL_TYPICAL_REACTIONS_NUM>::markAtom(Atom *atom)
{
    Collector<Atom, 1>::store<0>(atom);
}

template <ushort SPECS_NUM, ushort DUAL_TYPICAL_REACTIONS_NUM>
void Scavenger<SPECS_NUM, DUAL_TYPICAL_REACTIONS_NUM>::clear()
{
    deleteAndClear<Atom, 1>();
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
