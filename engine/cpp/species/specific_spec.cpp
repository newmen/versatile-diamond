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
#ifdef PARALLEL
#pragma omp critical (print)
#endif // PARALLEL
    {
        std::cout << "Removing reactions for " << name() << " with atoms of: " << std::endl;
        std::cout << std::dec;
        eachAtom([](Atom *atom) {
            atom->info();
            std::cout << std::endl;
        });
        std::cout << std::endl;
    }
#endif // PRINT

    for (uint i = 0; i < n; ++i)
    {
        reactionsDup[i]->removeFrom(this);
    }

    delete [] reactionsDup;
    BaseSpec::remove();
}

}
