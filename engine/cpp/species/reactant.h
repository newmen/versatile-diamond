#ifndef REACTANT_H
#define REACTANT_H

#include <unordered_map>
#include "../atoms/atom.h"
#include "../tools/common.h"

namespace vd
{

template <class R>
class Reactant
{
    typedef std::unordered_multimap<ushort, R *> Reactions;

    Reactions _reactions;
    bool _isNew = true;

public:
    virtual ~Reactant() {}

    virtual ushort type() const = 0;
    virtual Atom *atom(ushort index) const = 0;

    void keep();

    void insertReaction(R *reaction);
    void eraseReaction(R *reaction);

    template <class CR> CR *checkoutReaction();
    template <class CR> CR *checkoutReactionWith(const Reactant<R> *other);
    template <class CR> CR *checkoutReactionNotWith(const Reactant<R> *other);
    bool haveReaction(R *reaction) const;

protected:
    Reactant() = default;

    void setNotNew() { _isNew = false; }
    Reactions &reactions() { return _reactions; }

    virtual void keepFirstTime() = 0;

private:
    R *checkoutReaction(ushort rid);
    R *checkoutReactionWith(ushort rid, const Reactant<R> *other);
    R *checkoutReactionNotWith(ushort rid, const Reactant<R> *other);

    template <class L>
    R *checkoutReactionOp(ushort rid, const Reactant<R> *other, const L &op);

    typename Reactions::const_iterator find(R *reaction) const;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class R>
void Reactant<R>::keep()
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
    R *result = checkoutReaction(CR::ID);
    return static_cast<CR *>(result);
}

template <class R>
template <class CR>
CR *Reactant<R>::checkoutReactionWith(const Reactant<R> *other)
{
    R *result = checkoutReactionWith(CR::ID, other);
    return static_cast<CR *>(result);
}

template <class R>
bool Reactant<R>::haveReaction(R *reaction) const
{
    return find(reaction) != _reactions.cend();
}

template <class R>
R *Reactant<R>::checkoutReaction(ushort rid)
{
#ifndef NDEBUG
    auto range = _reactions.equal_range(rid);
    assert(std::distance(range.first, range.second) < 2);
#endif // NDEBUG

    auto pr = _reactions.find(rid);
    return (pr != _reactions.cend()) ? pr->second : nullptr;
}

template <class R>
R *Reactant<R>::checkoutReactionWith(ushort rid, const Reactant<R> *other)
{
    return checkoutReactionOp(rid, other, [](const R *a, const R *b) {
        return a == b;
    });
}

template <class R>
R *Reactant<R>::checkoutReactionNotWith(ushort rid, const Reactant<R> *other)
{
    return checkoutReactionOp(rid, other, [](const R *a, const R *b) {
        return a != b;
    });
}

template <class R>
template <class L>
R *Reactant<R>::checkoutReactionOp(ushort rid, const Reactant<R> *other, const L &op)
{
    auto currentRange = _reactions.equal_range(rid);
    auto anotherRange = other->_reactions.equal_range(rid);

    R *result = nullptr;
    for (; currentRange.first != currentRange.second; ++currentRange.first)
    {
        auto currentReaction = currentRange.first->second;
        auto anotherRangeBegin = anotherRange.first;

        for (; anotherRangeBegin != anotherRange.second; ++anotherRangeBegin)
        {
            if (op(currentReaction, anotherRangeBegin->second))
            {
                result = currentReaction;
                goto break_both_loops;
            }
        }
    }

    break_both_loops :;
    return result;
}

template <class R>
typename Reactant<R>::Reactions::const_iterator Reactant<R>::find(R *reaction) const
{
    auto range = _reactions.equal_range(reaction->type());
    for (; range.first != range.second; ++range.first)
    {
        if (range.first->second == reaction)
        {
            return range.first;
        }
    }

    return _reactions.cend();
}

}

#endif // REACTANT_H
