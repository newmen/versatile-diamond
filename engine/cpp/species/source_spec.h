#ifndef SOURCE_SPEC_H
#define SOURCE_SPEC_H

#include "../atoms/atom.h"

namespace vd
{

template <class B, ushort ATOMS_NUM>
class SourceSpec : public B
{
    Atom *_atoms[ATOMS_NUM];

protected:
    SourceSpec(Atom **atoms);

public:
    ushort size() const { return ATOMS_NUM; }
    Atom *atom(ushort index) const;

#ifdef PRINT
    void info(std::ostream &os) override;
    void eachAtom(const std::function<void (Atom *)> &lambda) override;
#endif // PRINT
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class B, ushort ATOMS_NUM>
SourceSpec<B, ATOMS_NUM>::SourceSpec(Atom **atoms)
{
    for (int i = 0; i < ATOMS_NUM; ++i)
    {
        _atoms[i] = atoms[i];
    }
}

template <class B, ushort ATOMS_NUM>
Atom *SourceSpec<B, ATOMS_NUM>::atom(ushort index) const
{
    assert(ATOMS_NUM > index);
    return _atoms[index];
}

#ifdef PRINT
template <class B, ushort ATOMS_NUM>
void SourceSpec<B, ATOMS_NUM>::info(std::ostream &os)
{
    os << this->name() << " at [" << this << "]";
    for (int i = 0; i < ATOMS_NUM; ++i)
    {
        os << " ";
        _atoms[i]->info(os);
    }
}

template <class B, ushort ATOMS_NUM>
void SourceSpec<B, ATOMS_NUM>::eachAtom(const std::function<void (Atom *)> &lambda)
{
    for (int i = 0; i < ATOMS_NUM; ++i)
    {
        lambda(_atoms[i]);
    }
}
#endif // PRINT

}

#endif // SOURCE_SPEC_H
