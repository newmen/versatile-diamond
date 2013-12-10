#ifndef REACTANT_H
#define REACTANT_H

#include <unordered_set>

namespace vd
{




template <class B, class R>
class Reactant : public B
{
    std::unordered_set<R *> _reactions;
    bool _isNew = true;

protected:
//    using B::B;
    template <class... Args>
    Reactant(Args... args) : B(args...) {}

    bool isNew() const { return _isNew; }

public:
    void usedIn(R *reaction) { _reactions.insert(reaction); }
    void unbindFrom(R *reaction) { _reactions.erase(reaction); }

#ifdef PRINT
    void remove() override;
#endif // PRINT

    void findReactions();

protected:
    virtual void findAllReactions() = 0;
    void findAllChildren() override {}

    R **reactionsDup(uint &n);
};

#ifdef PRINT
template <class B, class R>
void Reactant<B, R>::remove()
{
    debugPrint([&](std::ostream &os) {
        os << "Removing reactions for " << name() << " with atoms of: " << std::endl;
        os << std::dec;
        eachAtom([&os](Atom *atom) {
            atom->info(os);
            os << std::endl;
        });
    });
    B::remove();
}
#endif // PRINT

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
    R **dup = new R *[_reactions.size()];

    for (R *reaction : _reactions)
    {
        dup[n++] = reaction;
    }

    return dup;
}

}


#endif // REACTANT_H
