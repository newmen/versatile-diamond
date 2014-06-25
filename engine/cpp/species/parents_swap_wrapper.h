#ifndef PARENTS_SWAP_WRAPPER_H
#define PARENTS_SWAP_WRAPPER_H

#include "../tools/common.h"
#include "../atoms/atom.h"
#include "dependent_spec.h"

namespace vd
{

template <class B, class S, ushort FROM, ushort TO>
class ParentsSwapWrapper : public B
{
public:
    Atom *atom(ushort index) const override;

protected:
    template <class... Args> ParentsSwapWrapper(Args... args) : B(args...) {}

private:
    ushort checkChange(ushort index) const;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class B, class S, ushort FROM, ushort TO>
Atom *ParentsSwapWrapper<B, S, FROM, TO>::atom(ushort index) const
{
    assert(index < this->size());

    ushort i = 0;
    S *self = static_cast<S *>(this->parent());
    ParentSpec *prt = nullptr;
    while (true)
    {
        prt = self->parent(checkChange(i));
        ushort sz = prt->size();
        if (index < sz) break;

        index -= sz;
        ++i;
    }

    assert(prt);
    return prt->atom(index);
}

template <class B, class S, ushort FROM, ushort TO>
ushort ParentsSwapWrapper<B, S, FROM, TO>::checkChange(ushort index) const
{
    if (index == FROM) return TO;
    else if (index == TO) return FROM;
    return index;
}

}

#endif // PARENTS_SWAP_WRAPPER_H
