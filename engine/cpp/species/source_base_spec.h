#ifndef SOURCE_BASE_SPEC_H
#define SOURCE_BASE_SPEC_H

#include "base_spec.h"

namespace vd
{

template <ushort ATOMS_NUM>
class SourceBaseSpec : public BaseSpec
{
    Atom *_atoms[ATOMS_NUM];

public:
    SourceBaseSpec(ushort type, Atom **atoms);

    Atom *atom(ushort index);
    ushort size() const { return ATOMS_NUM; }
};

template <ushort ATOMS_NUM>
SourceBaseSpec<ATOMS_NUM>::SourceBaseSpec(ushort type, Atom **atoms) : BaseSpec(type)
{
    for (int i = 0; i < ATOMS_NUM; ++i)
    {
        _atoms[i] = atoms[i];
    }
}

template <ushort ATOMS_NUM>
Atom *SourceBaseSpec<ATOMS_NUM>::atom(ushort index)
{
    assert(ATOMS_NUM > index);
    return _atoms[index];
}

}

#endif // SOURCE_BASE_SPEC_H
