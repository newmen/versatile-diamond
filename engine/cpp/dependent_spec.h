#ifndef DEPENDENT_SPEC_H
#define DEPENDENT_SPEC_H

#include "base_spec.h"

namespace vd
{

template <ushort ATOMS_NUM>
class DependentSpec : public SourceBaseSpec<ATOMS_NUM>
{
    BaseSpec *_parents[ATOMS_NUM];

protected:
    DependentSpec(ushort type, BaseSpec **parents, Atom **atoms);

    BaseSpec *parent(ushort index = 0);
};

template <ushort ATOMS_NUM>
DependentSpec<ATOMS_NUM>::DependentSpec(ushort type, BaseSpec **parents, Atom **atoms) : SourceBaseSpec<ATOMS_NUM>(type, atoms)
{
    for (int i = 0; i < ATOMS_NUM; ++i)
    {
        _parents[i] = parents[i];
    }
}

template <ushort ATOMS_NUM>
BaseSpec *DependentSpec<ATOMS_NUM>::parent(ushort index)
{
    return _parents[index];
}

}

#endif // DEPENDENT_SPEC_H
