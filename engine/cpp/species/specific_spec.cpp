#include "specific_spec.h"

namespace vd
{

void SpecificSpec::usedIn(SpecReaction *reaction)
{
    _reactions.insert(reaction);
}

void SpecificSpec::unbindFrom(SpecReaction *reaction)
{
    _reactions.erase(reaction);
}

void SpecificSpec::remove()
{
    uint n = 0;
    SpecReaction **reactionsDup = new SpecReaction *[_reactions.size()];

    for (SpecReaction *reaction : _reactions)
    {
        reactionsDup[n++] = reaction;
    }

#ifdef PRINT
    debugPrint([&](std::ostream &os) {
        os << "Removing reactions for " << name() << " with atoms of: " << std::endl;
        os << std::dec;
        eachAtom([&os](Atom *atom) {
            atom->info();
            os << std::endl;
        });
    });
#endif // PRINT

    for (uint i = 0; i < n; ++i)
    {
        reactionsDup[i]->removeFrom(this);
    }

    delete [] reactionsDup;
    DependentSpec::remove();
}

void SpecificSpec::findReactions()
{
    findAllReactions();
    _isNew = false;
}

}
