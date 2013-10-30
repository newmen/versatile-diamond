#include "specific_spec.h"

namespace vd
{

SpecificSpec::SpecificSpec(ushort type, BaseSpec *parent) : DependentSpec<1>(type, &parent)
{
}

void SpecificSpec::usedIn(SpecReaction *reaction)
{
#ifdef PARALLEL
    lock([this, reaction]() {
#endif // PARALLEL
        _reactions.insert(reaction);
#ifdef PARALLEL
    });
#endif // PARALLEL
}

void SpecificSpec::unbindFrom(SpecReaction *reaction)
{
#ifdef PARALLEL
    lock([this, reaction]() {
#endif // PARALLEL
        _reactions.erase(reaction);
#ifdef PARALLEL
    });
#endif // PARALLEL
}

void SpecificSpec::removeReactions()
{
    SpecReaction **reactionsDup;
    int n = 0;

#ifdef PARALLEL
    lock([this, &reactionsDup, &n] {
#endif // PARALLEL
        reactionsDup = new SpecReaction *[_reactions.size()];
        for (SpecReaction *reaction : _reactions)
        {
            reactionsDup[n++] = reaction;
        }
#ifdef PARALLEL
    });
#endif // PARALLEL

#ifdef PRINT
#ifdef PARALLEL
#pragma omp critical (print)
    {
#endif // PARALLEL
        std::cout << std::dec;
        std::cout << "Atoms of " << name() << ": " << std::endl;
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
