#include "specific_spec.h"

namespace vd
{

SpecificSpec::SpecificSpec(ushort type, BaseSpec *parent) : DependentSpec<1>(type, &parent)
{
}

void SpecificSpec::usedIn(SpecReaction *reaction)
{
    _reactions.insert(reaction);
}

void SpecificSpec::unbindFrom(SpecReaction *reaction)
{
    _reactions.erase(reaction);
}

void SpecificSpec::removeReactions()
{
    SpecReaction **reactionsDup;
    int n = 0;

    reactionsDup = new SpecReaction *[_reactions.size()];
    for (SpecReaction *reaction : _reactions)
    {
        reactionsDup[n++] = reaction;
    }

#ifdef PRINT
#ifdef PARALLEL
#pragma omp critical (print)
    {
#endif // PARALLEL
        std::cout << "Removing reactions for " << name() << " with atoms of: " << std::endl;
        std::cout << std::dec;
        eachAtom([](Atom *atom) {
            atom->info();
            std::cout << std::endl;
        });
        std::cout << std::endl;
#ifdef PARALLEL
    }
#endif // PARALLEL
#endif // PRINT

    for (int i = 0; i < n; ++i)
    {
        SpecReaction *reaction = reactionsDup[i];
        reaction->removeFrom(this);
    }

    delete [] reactionsDup;
}

}
