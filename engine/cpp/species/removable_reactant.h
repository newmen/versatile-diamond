#ifndef REMOVABLE_REACTANT_H
#define REMOVABLE_REACTANT_H

#include "../tools/common.h"

namespace vd
{

template <class B>
class RemovableReactant : public B
{
public:
    void remove() override;

protected:
//    using B::B;
    template <class... Args>
    RemovableReactant(Args... args) : B(args...) {}
};

template<class B>
void RemovableReactant<B>::remove()
{
    uint n = 0;
    auto dup = this->reactionsDup(n);

    for (uint i = 0; i < n; ++i)
    {
        dup[i]->removeFrom(this);
    }

    delete [] dup;
}

}

#endif // REMOVABLE_REACTANT_H
