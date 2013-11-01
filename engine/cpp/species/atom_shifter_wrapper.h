#ifndef ATOM_SHIFTER_WRAPPER_H
#define ATOM_SHIFTER_WRAPPER_H

#include "../tools/common.h"
#include "../atoms/atom.h"
#include "base_spec.h"

namespace vd
{

template <class B>
class AtomShifterWrapper : public B
{
    ushort _atomsShift;

public:
//    using B::B;
    template <class T>
    AtomShifterWrapper(ushort type, T *parent, ushort atomsShift) : B(type, parent), _atomsShift(atomsShift) {}

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
