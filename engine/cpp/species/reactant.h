#ifndef REACTANT_H
#define REACTANT_H

#include <assert.h>
#include <unordered_map>

namespace vd
{

template <class B, class R>
class Reactant : public B
{
    std::unordered_multimap<ushort, R *> _reactions;
    bool _isNew = true;

public:
    void usedIn(R *reaction);
    void unbindFrom(R *reaction);

    template <class CR> CR *reaction();
    template <class CR, class S> CR *reactionWith(S *spec);

    void findReactions();

protected:
    template <class... Args>
    Reactant(Args... args) : B(args...) {}

    bool isNew() const { return _isNew; }

    virtual void findAllReactions() = 0;
    void findAllChildren() override {}

    R **reactionsDup(uint &n);
};

template <class B, class R>
void Reactant<B, R>::usedIn(R *reaction)
{
    _reactions.insert(std::pair<ushort, R *>(reaction->type(), reaction));
}

template <class B, class R>
void Reactant<B, R>::unbindFrom(R *reaction)
{
    auto range = _reactions.equal_range(reaction->type());
    assert(std::distance(range.first, range.second) > 0);

    while (range.first != range.second)
    {
        if (range.first->second == reaction)
        {
            _reactions.erase(range.first);
            break;
        }
        ++range.first;
    }
}

template <class B, class R>
template <class CR>
CR *Reactant<B, R>::reaction()
{
#ifdef DEBUG
    auto range = _reactions.equal_range(CR::ID);
    assert(std::distance(range.first, range.second) < 2);
#endif // DEBUG

    auto pr = _reactions.find(CR::ID);
    if (pr == _reactions.cend())
    {
        return nullptr;
    }
    else
    {
#ifdef DEBUG
        auto dynamicResult = dynamic_cast<CR *>(pr->second);
        assert(dynamicResult);
        return dynamicResult;
#else
        return static_cast<CR *>(pr->second);
#endif // DEBUG
    }
}

template <class B, class R>
template <class CR, class S>
CR *Reactant<B, R>::reactionWith(S *spec)
{
    auto currentRange = _reactions.equal_range(CR::ID);
    auto anotherRange = spec->_reactions.equal_range(CR::ID);

    R *result = nullptr;
    while (currentRange.first != currentRange.second)
    {
        auto currentReaction = currentRange.first->second;
        auto anotherRangeBegin = anotherRange.first;

        while (anotherRangeBegin != anotherRange.second)
        {
            if (currentReaction == anotherRangeBegin->second)
            {
                result = currentReaction;
                goto break_two_times;
            }
            ++anotherRangeBegin;
        }
        ++currentRange.first;
    }

    break_two_times :;

    if (result)
    {
#ifdef DEBUG
        auto dynamicResult = dynamic_cast<CR *>(result);
        assert(dynamicResult);
        return dynamicResult;
#else
        return static_cast<CR *>(result);
#endif // DEBUG
    }

    return nullptr;
}

template <class B, class R>
void Reactant<B, R>::findReactions()
{
    findAllReactions();
    _isNew = false;
}

template <class B, class R>
R **Reactant<B, R>::reactionsDup(uint &n)
{
    n = 0;

    if (_reactions.size() == 0)
    {
        return nullptr;
    }
    else
    {
        R **dup = new R *[_reactions.size()];

        for (auto &pr : _reactions)
        {
            dup[n++] = pr.second;
        }

        return dup;
    }
}

}


#endif // REACTANT_H
