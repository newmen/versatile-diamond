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

    void sort();

#ifdef SERIALIZE
    StepsSerializer::Dict counts();
#endif // SERIALIZE

    double totalRate() const final { return _tree.totalRate(); }

    void add(ushort index, SpecReaction *reaction) final;
    void remove(ushort index, SpecReaction *reaction) final;

    void add(ushort index, UbiquitousReaction *reaction, ushort n) final;
    void remove(ushort index, UbiquitousReaction *templateReaction, ushort n) final;
    void removeAll(ushort index, UbiquitousReaction *templateReaction) final;
    bool check(ushort index, Atom *target);

#ifndef NDEBUG
    void doOneOfOne(ushort rt) final;
    void doLastOfOne(ushort rt) final;

    void doOneOfMul(ushort rt) final;
    void doOneOfMul(ushort rt, int x, int y, int z) final;
    void doLastOfMul(ushort rt) final;
#endif // NDEBUG

private:
    TreeMC(const TreeMC &) = delete;
    TreeMC(TreeMC &&) = delete;
    TreeMC &operator = (const TreeMC &) = delete;
    TreeMC &operator = (TreeMC &&) = delete;

    Reaction *mostProbablyEvent(double r);
};

//////////////////////////////////////////////////////////////////////////////////////

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::TreeMC()
{
}

#ifdef SERIALIZE
template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
StepsSerializer::Dict TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::counts()
{
}
#endif // SERIALIZE

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
double TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::doRandom(CommonMCData *data)
{
    double r = data->rand(totalRate());
    Reaction *event = mostProbablyEvent(r);
    if (event)
    {
#if defined(PRINT) || defined(MC_PRINT)
        debugPrint([&](IndentStream &os) {
            os << event->name();
        });
#endif // PRINT || MC_PRINT

        data->counter()->inc(event);
        event->doIt();
        return increaseTime(data);
    }
    else
    {
#if defined(PRINT) || defined(MC_PRINT)
        debugPrint([&](IndentStream &os) {
            os << "Event not found! Recount and sort!";
        });
#endif // PRINT || MC_PRINT

        recountTotalRate();
        sort();

        if (totalRate() == 0)
        {
            return -1;
        }
        else
        {
            return doRandom(data);
        }
    }
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::recountTotalRate()
{
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::sort()
{
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::add(ushort index, SpecReaction *reaction)
{
#if defined(PRINT) || defined(MC_PRINT)
    printReaction(reaction, "Add", "one");
#endif // PRINT || MC_PRINT

    assert(index < EVENTS_NUM);

    _events[index].add(reaction);
    updateRate(reaction->rate());
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::remove(ushort index, SpecReaction *reaction)
{
#if defined(PRINT) || defined(MC_PRINT)
    printReaction(reaction, "Remove", "one");
#endif // PRINT || MC_PRINT

    assert(index < EVENTS_NUM);

    updateRate(-reaction->rate());
    _events[index].remove(reaction);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::add(ushort index, UbiquitousReaction *reaction, ushort n)
{
#if defined(PRINT) || defined(MC_PRINT)
    printReaction(reaction, "Add", "multi", n);
#endif // PRINT || MC_PRINT

    assert(index < MULTI_EVENTS_NUM);
    assert(n < reaction->target()->valence());

    _multiEvents[index].add(reaction, n);
    updateRate(reaction->rate() * n);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::remove(ushort index, UbiquitousReaction *templateReaction, ushort n)
{
#if defined(PRINT) || defined(MC_PRINT)
    printReaction(templateReaction, "Remove", "multi", n);
#endif // PRINT || MC_PRINT

    assert(index < MULTI_EVENTS_NUM);
    assert(n < templateReaction->target()->valence());

    updateRate(-templateReaction->rate() * n);
    _multiEvents[index].remove(templateReaction->target(), n);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::removeAll(ushort index, UbiquitousReaction *templateReaction)
{
    assert(index < MULTI_EVENTS_NUM);
    uint n = _multiEvents[index].removeAll(templateReaction->target());
    if (n > 0)
    {
#if defined(PRINT) || defined(MC_PRINT)
    printReaction(templateReaction, "Remove all", "multi", n);
#endif // PRINT || MC_PRINT

        assert(n < templateReaction->target()->valence());
        updateRate(-templateReaction->rate() * n);
    }
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
bool TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::check(ushort index, Atom *target)
{
    assert(index < MULTI_EVENTS_NUM);
    return _multiEvents[index].check(target);
}

#ifndef NDEBUG
template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::doOneOfOne(ushort rt)
{
    assert(rt < EVENTS_NUM);
    _events[rt].selectEvent(0)->doIt();
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::doLastOfOne(ushort rt)
{
    assert(rt < EVENTS_NUM);
    _events[rt].selectEvent((_events[rt].size() - 0.5) * _events[rt].oneRate())->doIt();
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::doOneOfMul(ushort rt)
{
    assert(rt < MULTI_EVENTS_NUM);
    _multiEvents[rt].selectEvent(0.0)->doIt();
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::doOneOfMul(ushort rt, int x, int y, int z)
{
    auto crd = int3(x, y, z);
    _multiEvents[rt].selectEventByCoords(crd)->doIt();
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::doLastOfMul(ushort rt)
{
    assert(rt < MULTI_EVENTS_NUM);
    _multiEvents[rt].selectEvent((_multiEvents[rt].size() - 0.5) * _multiEvents[rt].oneRate())->doIt();
}
#endif // NDEBUG

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
Reaction *TreeMC<EVENTS_NUM, MULTI_EVENTS_NUM>::mostProbablyEvent(double r)
{
#if defined(PRINT) || defined(MC_PRINT)
    debugPrint([&](IndentStream &os) {
        os << "MC::mostProbablyEvent()\n";
        os << "Random number: " << r << "\n";
    });
#endif // PRINT || MC_PRINT

    Reaction *event = nullptr;
    double passRate = 0;
    for (int i = 0; i < EVENTS_NUM + MULTI_EVENTS_NUM; ++i)
    {
        BaseEventsContainer *currentEvents = events(i);
        double cr = currentEvents->commonRate();
        if (r < cr + passRate)
        {
#if defined(PRINT) || defined(MC_PRINT)
            debugPrint([&](IndentStream &os) {
                os << "event " << i;
            });
#endif // PRINT || MC_PRINT

            event = currentEvents->selectEvent(r - passRate);
            break;
        }
        else
        {
            passRate += cr;
        }
    }

    return event;
}

}

#endif // TREE_MC_H
