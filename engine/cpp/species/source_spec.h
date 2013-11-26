#ifndef SOURCE_SPEC_H
#define SOURCE_SPEC_H

#include "base_spec.h"

#ifdef PRINT
#include <iostream>
#include "../tools/debug_print.h"
#endif // PRINT

namespace vd
{

template <ushort ATOMS_NUM>
class SourceSpec : public BaseSpec
{
    Atom *_atoms[ATOMS_NUM];

protected:
    SourceSpec(Atom **atoms);

public:
    ushort size() const { return ATOMS_NUM; }
    Atom *atom(ushort index) const;

    Atom *firstLatticedAtomIfExist() override;

#ifdef PRINT
    void info() override;
    void eachAtom(const std::function<void (Atom *)> &lambda) override;
#endif // PRINT
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

template <ushort ATOMS_NUM>
Atom *SourceSpec<ATOMS_NUM>::firstLatticedAtomIfExist()
{
    Atom *first = _atoms[0];
    if (first->lattice()) return first;

    for (int i = 1; i < ATOMS_NUM; ++i)
    {
        if (_atoms[i]->lattice()) return _atoms[i];
    }

    return first;
}

#ifdef PRINT
template <ushort ATOMS_NUM>
void SourceSpec<ATOMS_NUM>::info()
{
    debugPrintWoLock([&](std::ostream &os) {
        os << name() << " at [" << this << "]";
        for (int i = 0; i < ATOMS_NUM; ++i)
        {
            os << " ";
            _atoms[i]->info();
        }
    }, false);
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
