#ifndef ATOM_SHIFTER_WRAPPER_H
#define ATOM_SHIFTER_WRAPPER_H

#include "../tools/common.h"
#include "../atoms/atom.h"

namespace vd
{

template <class B>
class AtomShifterWrapper : public B
{
    ushort _atomsShift;

public:
    template <class... Ts>
    AtomShifterWrapper(ushort atomsShift, Ts... args) : B(args...), _atomsShift(atomsShift) {}

    Atom *atom(ushort index) override;
};

template <class B>
Atom *AtomShifterWrapper<B>::atom(ushort index)
{
    ushort shiftedIndex = index + _atomsShift;
    if (shiftedIndex >= this->size()) shiftedIndex -= this->size();
    return B::atom(shiftedIndex);
}

}

#endif // ATOM_SHIFTER_WRAPPER_H
