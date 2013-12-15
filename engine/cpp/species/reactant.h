#ifndef REACTANT_H
#define REACTANT_H

#include <assert.h>
#include <unordered_map>
#include "base_spec.h"

namespace vd
{

template <class R>
class Reactant : virtual public BaseSpec
{
    typedef std::unordered_multimap<ushort, R *> Reactions;

    Reactions _reactions;
    bool _isNew = true;

public:
    void store() override;

    void insertReaction(R *reaction);
    void eraseReaction(R *reaction);

    template <class CR> CR *checkoutReaction(); // TODO: is never used now?
    template <class CR, class S> CR *checkoutReactionWith(S *spec);
    bool haveReaction(R *reaction) const;

    void findReactions();

protected:
    virtual void keepFirstTime() = 0;
    virtual void findAllReactions() = 0;

    template <class L>
    void eachDupReaction(const L &lambda);

private:
    R **reactionsDup(uint &n);
    typename Reactions::const_iterator find(R *reaction) const;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class R>
void Reactant<R>::store()
{
    if (_isNew)
    {
        keepFirstTime();
    }
}

template <class R>
void Reactant<R>::insertReaction(R *reaction)
{
    assert(!haveReaction(reaction));
    _reactions.insert(std::pair<ushort, R *>(reaction->type(), reaction));
}

template <class R>
void Reactant<R>::eraseReaction(R *reaction)
{
    auto pr = find(reaction);
    assert(pr != _reactions.cend());
    _reactions.erase(pr);
}

template <class R>
template <class CR>
CR *Reactant<R>::checkoutReaction()
{
#ifdef DEBUG
    auto range = _reactions.equal_range(CR::ID);
    assert(std::distance(range.first, range.second) < 2);
#endif // DEBUG

    auto pr = _reactions.find(CR::ID);
    if (pr != _reactions.cend())
    {
#ifdef DEBUG
        auto dynamicResult = dynamic_cast<CR *>(pr->second);
        assert(dynamicResult);
        return dynamicResult;
#else
        return static_cast<CR *>(pr->second);
#endif // DEBUG
    }

    return nullptr;
}

template <class R>
template <class CR, class S>
CR *Reactant<R>::checkoutReactionWith(S *spec)
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

template <class R>
bool Reactant<R>::haveReaction(R *reaction) const
{
    return find(reaction) != _reactions.cend();
}

template <class R>
void Reactant<R>::findReactions()
{
    findAllReactions();
    _isNew = false;
}

template <class R>
template <class L>
void Reactant<R>::eachDupReaction(const L &lambda)
{
    uint n = 0;
    auto dup = reactionsDup(n);

    if (n > 0)
    {
        for (uint i = 0; i < n; ++i)
        {
            lambda(dup[i]);
        }

        delete [] dup;
    }
}

template <class R>
R **Reactant<R>::reactionsDup(uint &n)
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

template <class R>
typename Reactant<R>::Reactions::const_iterator Reactant<R>::find(R *reaction) const
{
    auto range = _reactions.equal_range(reaction->type());
    while (range.first != range.second)
    {
        if (range.first->second == reaction)
        {
            return range.first;
        }
        ++range.first;
    }

    return _reactions.cend();
}

}

#endif // REACTANT_H
