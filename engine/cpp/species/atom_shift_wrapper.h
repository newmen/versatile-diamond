#ifndef ATOM_SHIFT_WRAPPER_H
#define ATOM_SHIFT_WRAPPER_H

#include "../tools/common.h"
#include "../atoms/atom.h"

namespace vd
{

template <class B>
class AtomShiftWrapper : public B
{
    ushort _atomsShift;

public:
    template <class... Ts>
    AtomShiftWrapper(ushort atomsShift, Ts... args) : B(args...), _atomsShift(atomsShift) {}

    Atom *atom(ushort index) const override;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class B>
Atom *AtomShiftWrapper<B>::atom(ushort index) const
{
    ushort shiftedIndex = index + _atomsShift;
    if (shiftedIndex >= this->size()) shiftedIndex -= this->size();
    return B::atom(shiftedIndex);
}

}

#endif // ATOM_SHIFT_WRAPPER_H
