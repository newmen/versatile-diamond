#ifndef ATOMS_SWAP_WRAPPER_H
#define ATOMS_SWAP_WRAPPER_H

#include "../tools/common.h"
#include "../atoms/atom.h"

namespace vd
{

template <class B, ushort FROM, ushort TO>
class AtomsSwapWrapper : public B
{
protected:
    template <class... Args> AtomsSwapWrapper(Args... args) : B(args...) {}

public:
    Atom *atom(ushort index) const override;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class B, ushort FROM, ushort TO>
Atom *AtomsSwapWrapper<B, FROM, TO>::atom(ushort index) const
{
    if (index == FROM) return B::atom(TO);
    else if (index == TO) return B::atom(FROM);
    else return B::atom(index);
}

}

#endif // ATOMS_SWAP_WRAPPER_H
