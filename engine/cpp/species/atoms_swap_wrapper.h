#ifndef ATOMS_SWAP_WRAPPER_H
#define ATOMS_SWAP_WRAPPER_H

#include "../tools/common.h"
#include "../atoms/atom.h"

namespace vd
{

template <class B>
class AtomsSwapWrapper : public B
{
    ushort _from, _to;

public:
    template <class... Ts>
    AtomsSwapWrapper(ushort from, ushort to, Ts... args) : B(args...), _from(from), _to(to) {}

    Atom *atom(ushort index) const override;
};

template <class B>
Atom *AtomsSwapWrapper<B>::atom(ushort index) const
{
    if (index == _from)
    {
        return B::atom(_to);
    }
    else if (index == _to)
    {
        return B::atom(_from);
    }
    else
    {
        return B::atom(index);
    }
}

}

#endif // ATOMS_SWAP_WRAPPER_H
