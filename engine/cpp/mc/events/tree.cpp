#include "tree.h"
#include <cmath>

namespace vd
{

ushort Tree::safeRound(double aprox)
{
    ushort result = (ushort)aprox;
    if (result + 1e-4 < aprox)
    {
        ++result;
    }
    return result;
}

ushort Tree::sliceSize(ushort num)
{
    const double aprox = pow(num, 1.0 / MAX_TREE_DEPTH);
    return safeRound(aprox);
}

Tree::Tree(ushort unoNums, ushort multiNums) :
    _oneEvents(unoNums, nullptr), _mulEvents(multiNums, nullptr)
{
    _root = buildRoot(unoNums, multiNums); // fills _oneEvents and _mulEvents

#ifndef NDEBUG
    for (SpecieEvents *events : _oneEvents)
    {
        assert(events);
    }
    for (AtomEvents *events : _mulEvents)
    {
        assert(events);
    }
#endif
}

Tree::~Tree()
{
    assert(_root);
    delete _root;
}

void Tree::sort()
{
    assert(_root);
    _root->sort();
}

void Tree::resetRate()
{
    assert(_root);
    return _root->resetRate();
}

double Tree::totalRate() const
{
    assert(_root);
    return _root->commonRate();
}

Reaction *Tree::selectEvent(double r)
{
    assert(_root);
    return _root->selectEvent(r);
}

void Tree::add(ushort index, SpecReaction *reaction)
{
    assert(index < _oneEvents.size());
    _oneEvents[index]->add(reaction);
}

void Tree::remove(ushort index, SpecReaction *reaction)
{
    assert(index < _oneEvents.size());
    _oneEvents[index]->remove(reaction);
}

void Tree::add(ushort index, UbiquitousReaction *reaction, ushort n)
{
    assert(index < _mulEvents.size());
    _mulEvents[index]->add(reaction, n);
}

void Tree::remove(ushort index, UbiquitousReaction *reaction, ushort n)
{
    assert(index < _mulEvents.size());
    _mulEvents[index]->remove(reaction, n);
}

void Tree::removeAll(ushort index, UbiquitousReaction *reaction)
{
    assert(index < _mulEvents.size());
    _mulEvents[index]->removeAll(reaction);
}

bool Tree::check(ushort index, Atom *target)
{
    assert(index < _mulEvents.size());
    _mulEvents[index]->check(target);
}

#ifndef NDEBUG
void Tree::doOneOfOne(ushort index)
{
    doFirstOf(_oneEvents, index);
}

void Tree::doLastOfOne(ushort index)
{
    doLastOf(_oneEvents, index);
}

void Tree::doOneOfMul(ushort index)
{
    doFirstOf(_mulEvents, index);
}

void Tree::doOneOfMul(ushort index, int x, int y, int z)
{
    assert(index < _mulEvents.size());
    auto crd = int3(x, y, z);
    _mulEvents[index]->selectEventByCoords(crd)->doIt();
}

void Tree::doLastOfMul(ushort index)
{
    doLastOf(_mulEvents, index);
}
#endif // NDEBUG

Slice *Tree::buildRoot(ushort unoNums, ushort multiNums)
{
    const ushort size = sliceSize(unoNums + multiNums);
    return buildSlice(nullptr, size, MAX_TREE_DEPTH - 1, unoNums, multiNums);
}

Slice *Tree::buildSlice(Slice *parent, ushort size, short depth, ushort unoPartNums, ushort mulPartNums)
{
    Slice *slice = new Slice(parent);
    if (depth <= 0)
    {
        appendEventsTo(slice, unoPartNums, mulPartNums);
    }
    else
    {
        appendSlicesTo(slice, size, depth, unoPartNums, mulPartNums);
    }
    return slice;
}

void Tree::appendEventsTo(Slice *slice, ushort unoPartNums, ushort mulPartNums)
{
    appendEventsTo<SpecieEvents>(slice, unoPartNums);
    appendEventsTo<AtomEvents>(slice, mulPartNums);
}

void Tree::appendSlicesTo(Slice *slice, ushort size, short depth, ushort unoPartNums, ushort mulPartNums)
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

void Tree::appendNodesTo(Slice *slice, ushort size, short depth, ushort unoPartNums, ushort mulPartNums)
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

void Tree::storeRef(ushort index, SpecieEvents *events)
{
    storeRef(&_oneEvents, index, events);
}

void Tree::storeRef(ushort index, AtomEvents *events)
{
    storeRef(&_mulEvents, index, events);
}

#ifdef JSONLOG
JSONStepsLogger::Dict Tree::counts() const
{
    JSONStepsLogger::Dict result;
    for (const SpecieEvents *events : _oneEvents)
    {
        appendNumsTo(&result, events);
    }
    for (const AtomEvents *events : _mulEvents)
    {
        appendNumsTo(&result, events);
    }

    return result;
}
#endif // JSONLOG

}
