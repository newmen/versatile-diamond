#ifndef ADDITIONAL_ATOMS_WRAPPER_H
#define ADDITIONAL_ATOMS_WRAPPER_H

#include "../tools/common.h"
#include "../atoms/atom.h"

namespace vd
{

template <class B, ushort ATOMS_NUM>
class AdditionalAtomsWrapper : public B
{
    Atom *_additionalAtoms[ATOMS_NUM];

public:
    template <class... Ts>
    AdditionalAtomsWrapper(Atom *additionalAtom, Ts... args);

    template <class... Ts>
    AdditionalAtomsWrapper(Atom **additionalAtoms, Ts... args);

    Atom *atom(ushort index) const override;
    ushort size() const override;

#ifdef PRINT
    void info(std::ostream &os) override;
    void eachAtom(const std::function<void (Atom *)> &lambda) override;
#endif // PRINT
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class B, ushort ATOMS_NUM>
template <class... Ts>
AdditionalAtomsWrapper<B, ATOMS_NUM>::AdditionalAtomsWrapper(Atom *additionalAtom, Ts... args) :
    AdditionalAtomsWrapper<B, ATOMS_NUM>(&additionalAtom, args...)
{
    static_assert(ATOMS_NUM == 1, "Wrong ATOMS_NUM value for using constructor");
}

template <class B, ushort ATOMS_NUM>
template <class... Ts>
AdditionalAtomsWrapper<B, ATOMS_NUM>::AdditionalAtomsWrapper(Atom **additionalAtoms, Ts... args) : B(args...)
{
    for (int i = 0; i < ATOMS_NUM; ++i)
    {
        _additionalAtoms[i] = additionalAtoms[i];
    }
}

template <class B, ushort ATOMS_NUM>
Atom *AdditionalAtomsWrapper<B, ATOMS_NUM>::atom(ushort index) const
{
    return (index < ATOMS_NUM) ? _additionalAtoms[index] : B::atom(index - ATOMS_NUM);
}

template <class B, ushort ATOMS_NUM>
ushort AdditionalAtomsWrapper<B, ATOMS_NUM>::size() const
{
    return ATOMS_NUM + B::size();
}

#ifdef PRINT
template <class B, ushort ATOMS_NUM>
void AdditionalAtomsWrapper<B, ATOMS_NUM>::info(std::ostream &os)
{
    B::info(os);
    os << " && additional: ";
    for (int i = 0; i < ATOMS_NUM; ++i)
    {
        os << " ";
        _additionalAtoms[i]->info(os);
    }
}

template <class B, ushort ATOMS_NUM>
void AdditionalAtomsWrapper<B, ATOMS_NUM>::eachAtom(const std::function<void (Atom *)> &lambda)
{
    for (int i = 0; i < ATOMS_NUM; ++i)
    {
        lambda(_additionalAtoms[i]);
    }

    B::eachAtom(lambda);
}
#endif // PRINT

}

#endif // ADDITIONAL_ATOMS_WRAPPER_H
