#ifndef REACTANT_H
#define REACTANT_H

#include <assert.h>
#include <unordered_set>

namespace vd
{

template <class B, class R>
class Reactant : public B
{
    std::unordered_set<R *> _reactions;
    bool _isNew = true;

public:
    void usedIn(R *reaction);
    void unbindFrom(R *reaction);

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
    assert(_reactions.find(reaction) == _reactions.cend());
    _reactions.insert(reaction);
}

template <class B, class R>
void Reactant<B, R>::unbindFrom(R *reaction)
{
    assert(_reactions.find(reaction) != _reactions.cend());
    _reactions.erase(reaction);
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

        for (R *reaction : _reactions)
        {
            dup[n++] = reaction;
        }

        return dup;
    }
}

}


#endif // REACTANT_H
