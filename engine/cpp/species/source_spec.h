#ifndef SOURCE_SPEC_H
#define SOURCE_SPEC_H

#include "parent_spec.h"

#ifdef PRINT
#include <iostream>
#include "../tools/debug_print.h"
#endif // PRINT

namespace vd
{

template <ushort ATOMS_NUM>
class SourceSpec : public ParentSpec
{
    Atom *_atoms[ATOMS_NUM];

protected:
    SourceSpec(Atom **atoms);

public:
    enum : ushort { UsedAtomsNum = ATOMS_NUM };

    ushort size() const { return ATOMS_NUM; }
    Atom *atom(ushort index) const;

#ifdef PRINT
    void info(std::ostream &os) override;
    void eachAtom(const std::function<void (Atom *)> &lambda) override;
#endif // PRINT

    template <class L>
    void eachParent(const L &) {}
};

template <ushort ATOMS_NUM>
SourceSpec<ATOMS_NUM>::SourceSpec(Atom **atoms)
{
    for (int i = 0; i < ATOMS_NUM; ++i)
    {
        _atoms[i] = atoms[i];
    }
}

template <ushort ATOMS_NUM>
Atom *SourceSpec<ATOMS_NUM>::atom(ushort index) const
{
    assert(ATOMS_NUM > index);
    return _atoms[index];
}

#ifdef PRINT
template <ushort ATOMS_NUM>
void SourceSpec<ATOMS_NUM>::info(std::ostream &os)
{
    os << name() << " at [" << this << "]";
    for (int i = 0; i < ATOMS_NUM; ++i)
    {
        os << " ";
        _atoms[i]->info(os);
    }
}

template <ushort ATOMS_NUM>
void SourceSpec<ATOMS_NUM>::eachAtom(const std::function<void (Atom *)> &lambda)
{
    for (int i = 0; i < ATOMS_NUM; ++i)
    {
        lambda(_atoms[i]);
    }
}
#endif // PRINT

}

#endif // SOURCE_SPEC_H
