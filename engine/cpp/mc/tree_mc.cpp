#include "tree_mc.h"

namespace vd
{

ushort TreeMC::safeRound(double aprox)
{
    ushort result = (ushort)aprox;
    if (result + 1e-4 < aprox)
    {
        ++result;
    }
    return result;
}

ushort TreeMC::sliceSize(ushort num)
{
    const double aprox = pow(num, 1.0 / MAX_TREE_DEPTH);
    return safeRound(aprox);
}

TreeMC::TreeMC(ushort unoNums, ushort multiNums) :
    _events(unoNums, nullptr), _multiEvents(multiNums, nullptr)
{
    _root = buildRoot(unoNums, multiNums); // fills _events and _multiEvents

#ifndef NDEBUG
    for (SpecieEvents *events : _events)
    {
        assert(events);
    }
    for (AtomEvents *events : _multiEvents)
    {
        assert(events);
    }
#endif
}

TreeMC::~TreeMC()
{
    assert(_root);
    delete _root;
}

void TreeMC::sort()
{
    if (!DISABLE_MC_SORT)
    {
        assert(_root);
        _root->sort();
    }
}

#ifdef JSONLOG
JSONStepsLogger::Dict TreeMC::counts() const
{
    JSONStepsLogger::Dict result;
    for (const SpecieEvents *events : _events)
    {
        appendNumsTo(&result, events);
    }
    for (const AtomEvents *events : _multiEvents)
    {
        appendNumsTo(&result, events);
    }

    return result;
}
#endif // JSONLOG

double TreeMC::totalRate() const
{
    assert(_root);
    return _root->commonRate();
}

void TreeMC::add(ushort index, SpecReaction *reaction)
{
    assert(index < _events.size());
    _events[index]->add(reaction);
}

void TreeMC::remove(ushort index, SpecReaction *reaction)
{
    assert(index < _events.size());
    _events[index]->remove(reaction);
}

void TreeMC::add(ushort index, UbiquitousReaction *reaction, ushort n)
{
    assert(index < _multiEvents.size());
    _multiEvents[index]->add(reaction, n);
}

void TreeMC::remove(ushort index, UbiquitousReaction *reaction, ushort n)
{
    assert(index < _multiEvents.size());
    _multiEvents[index]->remove(reaction, n);
}

void TreeMC::removeAll(ushort index, UbiquitousReaction *reaction)
{
    assert(index < _multiEvents.size());
    _multiEvents[index]->removeAll(reaction);
}

bool TreeMC::check(ushort index, Atom *target)
{
    assert(index < _multiEvents.size());
    return _multiEvents[index]->check(target);
}

#ifndef NDEBUG
void TreeMC::doOneOfOne(ushort index)
{
    doFirstOf(_events, index);
}

void TreeMC::doLastOfOne(ushort index)
{
    doLastOf(_events, index);
}

void TreeMC::doOneOfMul(ushort index)
{
    doFirstOf(_multiEvents, index);
}

void TreeMC::doOneOfMul(ushort index, int x, int y, int z)
{
    assert(index < _multiEvents.size());
    auto crd = int3(x, y, z);
    _multiEvents[index]->selectEventByCoords(crd)->doIt();
}

void TreeMC::doLastOfMul(ushort index)
{
    doLastOf(_multiEvents, index);
}
#endif // NDEBUG

uint TreeMC::totalEventsNum() const
{
    return _events.size() + _multiEvents.size();
}

void TreeMC::recountTotalRate()
{
    assert(_root);
    return _root->resetRate();
}

Reaction *TreeMC::mostProbablyEvent(double r)
{
    assert(_root);
    return _root->selectEvent(r);
}

Slice *TreeMC::buildRoot(ushort unoNums, ushort multiNums)
{
    const ushort size = sliceSize(unoNums + multiNums);
    return buildSlice(nullptr, size, MAX_TREE_DEPTH - 1, unoNums, multiNums);
}

Slice *TreeMC::buildSlice(Slice *parent, ushort size, short depth, ushort unoPartNums, ushort mulPartNums)
{
    assert(depth >= 0);
    Slice *slice = new Slice(parent);
    if (depth == 0)
    {
        appendEventsTo(slice, unoPartNums, mulPartNums);
    }
    else
    {
        appendSlicesTo(slice, size, depth, unoPartNums, mulPartNums);
    }
    return slice;
}

void TreeMC::appendEventsTo(Slice *slice, ushort unoPartNums, ushort mulPartNums)
{
    appendEventsTo<SpecieEvents>(slice, unoPartNums);
    appendEventsTo<AtomEvents>(slice, mulPartNums);
}

void TreeMC::appendSlicesTo(Slice *slice, ushort size, short depth, ushort unoPartNums, ushort mulPartNums)
{
    const double aprox = (double)(unoPartNums + mulPartNums) / size;
    const ushort subSize = safeRound(aprox);

    for (ushort i = 0; i < size; ++i)
    {
        ushort tn = 0, mn = 0;
        if (subSize > unoPartNums)
        {
            const ushort restNums = subSize - unoPartNums;
            mn = (restNums > mulPartNums) ? mulPartNums : restNums;
            tn = unoPartNums;
        }
        else
        {
            tn = subSize;
        }
        assert(tn + mn > 0);
        appendNodesTo(slice, size, depth, tn, mn);

        unoPartNums -= tn;
        mulPartNums -= mn;
        if (unoPartNums == 0 && mulPartNums == 0)
        {
            break;
        }
    }
}

void TreeMC::appendNodesTo(Slice *slice, ushort size, short depth, ushort unoPartNums, ushort mulPartNums)
{
    if (unoPartNums + mulPartNums == 1)
    {
        appendEventsTo(slice, unoPartNums, mulPartNums);
    }
    else
    {
        slice->addNode(buildSlice(slice, size, depth-1, unoPartNums, mulPartNums));
    }
}

void TreeMC::storeRef(ushort index, SpecieEvents *events)
{
    storeRef(&_events, index, events);
}

void TreeMC::storeRef(ushort index, AtomEvents *events)
{
    storeRef(&_multiEvents, index, events);
}

}
