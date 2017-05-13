#ifndef TREE_MC_H
#define TREE_MC_H

#include "events/tree.h"
#include "base_mc.h"

namespace vd
{

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
class TreeMC : public BaseMC<EVENTS_NUM, MULTI_EVENTS_NUM>
{
    Tree _tree;
    double _totalTime;

public:
    TreeMC();

    void sort() final;

#ifdef JSONLOG
    JSONStepsLogger::Dict counts() const;
#endif // JSONLOG

    double totalRate() const final { return _tree.totalRate(); }

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
#endif // NDEBUG

protected:
    void recountTotalRate() final;

private:
    TreeMC(const TreeMC &) = delete;
    TreeMC(TreeMC &&) = delete;
    TreeMC &operator = (const TreeMC &) = delete;
    TreeMC &operator = (TreeMC &&) = delete;

    Reaction *mostProbablyEvent(double r);
};

//////////////////////////////////////////////////////////////////////////////////////

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::TreeMC() : _tree(EVENTS_NUM, MULTI_EVENTS_NUM)
{
}

#ifdef JSONLOG
template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
JSONStepsLogger::Dict TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::counts() const
{
    return _tree.counts();
}
#endif // JSONLOG

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::recountTotalRate()
{
    _tree.resetRate();
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::sort()
{
    _tree.sort();
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::add(ushort index, SpecReaction *reaction)
{
    assert(index < EVENTS_NUM);
    _tree.add(index, reaction);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::remove(ushort index, SpecReaction *reaction)
{
    assert(index < EVENTS_NUM);
    _tree.remove(index, reaction);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::add(ushort index, UbiquitousReaction *reaction, ushort n)
{
    assert(index < MULTI_EVENTS_NUM);
    _tree.add(index, reaction, n);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::remove(ushort index, UbiquitousReaction *reaction, ushort n)
{
    assert(index < MULTI_EVENTS_NUM);
    _tree.remove(index, reaction, n);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::removeAll(ushort index, UbiquitousReaction *reaction)
{
    assert(index < MULTI_EVENTS_NUM);
    _tree.removeAll(index, reaction);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
bool TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::check(ushort index, Atom *target)
{
    assert(index < MULTI_EVENTS_NUM);
    return _tree.check(index, target);
}

#ifndef NDEBUG
template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::doOneOfOne(ushort index)
{
    assert(index < EVENTS_NUM);
    _tree.doOneOfOne(index);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::doLastOfOne(ushort index)
{
    assert(index < EVENTS_NUM);
    _tree.doLastOfOne(index);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::doOneOfMul(ushort index)
{
    assert(index < MULTI_EVENTS_NUM);
    return _tree.doOneOfMul(index);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::doOneOfMul(ushort index, int x, int y, int z)
{
    assert(index < MULTI_EVENTS_NUM);
    return _tree.doOneOfMul(index, x, y, z);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::doLastOfMul(ushort index)
{
    assert(index < MULTI_EVENTS_NUM);
    return _tree.doLastOfMul(index);
}
#endif // NDEBUG

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
Reaction *TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::mostProbablyEvent(double r)
{
    return _tree.selectEvent(r);
}

}

#endif // TREE_MC_H
