#ifndef TREE_H
#define TREE_H

#include <vector>
#include "../../tools/common.h"
#include "../../tools/steps_serializer.h"
#include "slice.h"
#include "atom_events.h"
#include "specie_events.h"

#define MAX_TREE_DEPTH 3

namespace vd
{

class Tree
{
    Slice *_root = nullptr;
    std::vector<SpecieEvents *> _oneEvents;
    std::vector<AtomEvents *> _mulEvents;

    static ushort safeRound(double aprox);
    static ushort sliceSize(ushort num);

public:
    Tree(ushort unoNums, ushort multiNums);
    ~Tree();

#ifdef SERIALIZE
    StepsSerializer::Dict counts() const;
#endif // SERIALIZE

    void sort();
    void resetRate();
    double totalRate() const;
    Reaction *selectEvent(double r);

    void add(ushort index, SpecReaction *reaction);
    void remove(ushort index, SpecReaction *reaction);

    void add(ushort index, UbiquitousReaction *reaction, ushort n);
    void remove(ushort index, UbiquitousReaction *reaction, ushort n);
    void removeAll(ushort index, UbiquitousReaction *reaction);
    bool check(ushort index, Atom *target);

#ifndef NDEBUG
    void doOneOfOne(ushort index);
    void doLastOfOne(ushort index);

    void doOneOfMul(ushort index);
    void doOneOfMul(ushort index, int x, int y, int z);
    void doLastOfMul(ushort index);

    template <class CN>
    void doFirstOf(std::vector<CN *> &events, ushort index);

    template <class CN>
    void doLastOf(std::vector<CN *> &events, ushort index);
#endif // NDEBUG

private:
    Tree(const Tree &) = delete;
    Tree(Tree &&) = delete;
    Tree &operator = (const Tree &) = delete;
    Tree &operator = (Tree &&) = delete;

    Slice *buildRoot(ushort unoNums, ushort multiNums);
    Slice *buildSlice(Slice *parent, ushort size, short depth, ushort unoPartNums, ushort mulPartNums);

    template <class CN>
    void appendEventsTo(Slice *slice, ushort num);
    void appendEventsTo(Slice *slice, ushort unoPartNums, ushort mulPartNums);
    void appendSlicesTo(Slice *slice, ushort size, short depth, ushort unoPartNums, ushort mulPartNums);
    void appendNodesTo(Slice *slice, ushort size, short depth, ushort unoPartNums, ushort mulPartNums);

    template <class CN>
    void storeRef(std::vector<CN *> *container, ushort index, CN *events);
    void storeRef(ushort index, SpecieEvents *events);
    void storeRef(ushort index, AtomEvents *events);

#ifdef SERIALIZE
    template <class CN>
    void appendNumsTo(StepsSerializer::Dict *dict, const CN *events) const;
#endif // SERIALIZE
};

//////////////////////////////////////////////////////////////////////////////////////

#ifndef NDEBUG
template <class CN>
void Tree::doFirstOf(std::vector<CN *> &events, ushort index)
{
    assert(index < events.size());
    events[index]->selectEvent(0)->doIt();
}

template <class CN>
void Tree::doLastOf(std::vector<CN *> &events, ushort index)
{
    assert(index < events.size());
    CN *container = events[index];
    container->selectEvent((container->size() - 0.5) * container->oneRate())->doIt();
}
#endif // NDEBUG

template <class CN>
void Tree::appendEventsTo(Slice *slice, ushort num)
{
    static ushort index = 0;

    for (ushort i = 0; i < num; ++i)
    {
        CN *events = new CN(slice);
        slice->addNode(events);
        storeRef(index++, events);
    }
}

template <class CN>
void Tree::storeRef(std::vector<CN *> *container, ushort index, CN *events)
{
    assert(index < container->size());
    assert(!(*container)[index]);
    (*container)[index] = events;
}

#ifdef SERIALIZE
template <class CN>
void Tree::appendNumsTo(StepsSerializer::Dict *dict, const CN *events) const
{
    uint size = events->size();
    if (size > 0)
    {
        (*dict)[events->name()] = size;
    }
}
#endif // SERIALIZE

}

#endif // TREE_H
