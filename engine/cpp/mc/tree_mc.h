#ifndef TREE_MC_H
#define TREE_MC_H

#include "base_mc.h"
#include "../tools/json_steps_logger.h"
#include "events/slice.h"
#include "events/atom_events.h"
#include "events/specie_events.h"

#define MAX_TREE_DEPTH 3

namespace vd
{

class TreeMC : public BaseMC
{
    Slice *_root = nullptr;
    std::vector<SpecieEvents *> _events;
    std::vector<AtomEvents *> _multiEvents;

    static ushort safeRound(double aprox);
    static ushort sliceSize(ushort num);

public:
    TreeMC(ushort eventsNum, ushort multiEventsNum);
    ~TreeMC();

    void sort() final;
    void halfSort() final;

#ifdef JSONLOG
    JSONStepsLogger::Dict counts() const;
#endif // JSONLOG

    double totalRate() const final;

    void add(ushort index, SpecReaction *reaction) final;
    void remove(ushort index, SpecReaction *reaction) final;

    void add(ushort index, UbiquitousReaction *reaction, ushort n) final;
    void remove(ushort index, UbiquitousReaction *reaction, ushort n) final;
    void removeAll(ushort index, UbiquitousReaction *reaction) final;
    bool check(ushort index, Atom *target);

#ifndef NDEBUG
    void doOneOfOne(ushort index) final;
    void doLastOfOne(ushort index) final;

    void doOneOfMul(ushort index) final;
    void doOneOfMul(ushort index, int x, int y, int z) final;
    void doLastOfMul(ushort index) final;

    template <class CN>
    void doFirstOf(std::vector<CN *> &events, ushort index);

    template <class CN>
    void doLastOf(std::vector<CN *> &events, ushort index);
#endif // NDEBUG

protected:
    uint totalEventsNum() const final;
    void recountTotalRate() final;
    Reaction *mostProbablyEvent(double r);

private:
    TreeMC(const TreeMC &) = delete;
    TreeMC(TreeMC &&) = delete;
    TreeMC &operator = (const TreeMC &) = delete;
    TreeMC &operator = (TreeMC &&) = delete;

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

#ifdef JSONLOG
    template <class CN>
    void appendNumsTo(JSONStepsLogger::Dict *dict, const CN *events) const;
#endif // JSONLOG
};

//////////////////////////////////////////////////////////////////////////////////////

#ifndef NDEBUG
template <class CN>
void TreeMC::doFirstOf(std::vector<CN *> &events, ushort index)
{
    assert(index < events.size());
    events[index]->selectEvent(0)->doIt();
}

template <class CN>
void TreeMC::doLastOf(std::vector<CN *> &events, ushort index)
{
    assert(index < events.size());
    CN *container = events[index];
    container->selectEvent((container->size() - 0.5) * container->oneRate())->doIt();
}
#endif // NDEBUG

template <class CN>
void TreeMC::appendEventsTo(Slice *slice, ushort num)
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
void TreeMC::storeRef(std::vector<CN *> *container, ushort index, CN *events)
{
    assert(index < container->size());
    assert(!(*container)[index]);
    (*container)[index] = events;
}

#ifdef JSONLOG
template <class CN>
void TreeMC::appendNumsTo(JSONStepsLogger::Dict *dict, const CN *events) const
{
    uint size = events->size();
    if (size > 0)
    {
        (*dict)[events->name()] = size;
    }
}
#endif // JSONLOG

}

#endif // TREE_MC_H
