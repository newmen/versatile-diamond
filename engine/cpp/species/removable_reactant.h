#ifndef REMOVABLE_REACTANT_H
#define REMOVABLE_REACTANT_H

#include "../atoms/atom.h"
#include "../tools/common.h"

namespace vd
{

template <class B>
class RemovableReactant : public B
{
public:
    void remove() override;

protected:
    template <class... Args>
    RemovableReactant(Args... args) : B(args...) {}
};

template<class B>
void RemovableReactant<B>::remove()
{
#ifdef PRINT
    debugPrint([&](std::ostream &os) {
        os << "Removing reactions for " << this->name() << " with atoms of: " << std::endl;
        os << std::dec;
        this->eachAtom([&os](Atom *atom) {
            atom->info(os);
            os << std::endl;
        });
    });
#endif // PRINT

    uint n = 0;
    auto dup = this->reactionsDup(n);

    if (n > 0)
    {
        for (uint i = 0; i < n; ++i)
        {
            dup[i]->removeFrom(this);
        }

        delete [] dup;
    }

    B::remove();
}

}

#endif // REMOVABLE_REACTANT_H
