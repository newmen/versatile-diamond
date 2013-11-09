#ifndef SOURCE_BASE_SPEC_H
#define SOURCE_BASE_SPEC_H

#include "base_spec.h"

#ifdef PRINT
#include <iostream>
#endif // PRINT

namespace vd
{

template <ushort ATOMS_NUM>
class SourceBaseSpec : public BaseSpec
{
    Atom *_atoms[ATOMS_NUM];

public:
    SourceBaseSpec(ushort type, Atom **atoms);

    ushort size() const { return ATOMS_NUM; }
    void eachAtom(const std::function<void (Atom *)> &lambda) override;
    Atom *atom(ushort index);

#ifdef PRINT
    void info() override;
#endif // PRINT
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

#ifdef PRINT
template <ushort ATOMS_NUM>
void SourceBaseSpec<ATOMS_NUM>::info()
{
    std::cout << name() << " at [" << this << "]";
    for (int i = 0; i < ATOMS_NUM; ++i)
    {
        std::cout << " ";
        _atoms[i]->info();
    }
}
#endif // PRINT

template <ushort ATOMS_NUM>
void SourceBaseSpec<ATOMS_NUM>::eachAtom(const std::function<void (Atom *)> &lambda)
{
    for (int i = 0; i < ATOMS_NUM; ++i)
    {
        lambda(_atoms[i]);
    }

}

}

#endif // SOURCE_BASE_SPEC_H
