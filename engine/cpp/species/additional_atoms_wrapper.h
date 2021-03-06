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

protected:
    template <class... Args> AdditionalAtomsWrapper(Atom *additionalAtom, Args... args);
    template <class... Args> AdditionalAtomsWrapper(Atom **additionalAtoms, Args... args);

public:
    Atom *atom(ushort index) const override;
    ushort size() const override;

#if defined(PRINT) || defined(SPEC_PRINT)
    void info(IndentStream &os) override;
    void eachAtom(const std::function<void (Atom *)> &lambda) override;
#endif // PRINT || SPEC_PRINT
};

//////////////////////////////////////////////////////////////////////////////////////

template <class B, ushort ATOMS_NUM>
template <class... Args>
AdditionalAtomsWrapper<B, ATOMS_NUM>::AdditionalAtomsWrapper(Atom *additionalAtom, Args... args) :
    AdditionalAtomsWrapper<B, ATOMS_NUM>(&additionalAtom, args...)
{
    static_assert(ATOMS_NUM == 1, "Wrong ATOMS_NUM value for using constructor");
}

template <class B, ushort ATOMS_NUM>
template <class... Args>
AdditionalAtomsWrapper<B, ATOMS_NUM>::AdditionalAtomsWrapper(Atom **additionalAtoms, Args... args) : B(args...)
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

#if defined(PRINT) || defined(SPEC_PRINT)
template <class B, ushort ATOMS_NUM>
void AdditionalAtomsWrapper<B, ATOMS_NUM>::info(IndentStream &os)
{
    B::info(os);

    IndentStream sub = indentStream(os);
    sub << "&& additional:";
    for (int i = 0; i < ATOMS_NUM; ++i)
    {
        IndentStream subSub = indentStream(sub);
        _additionalAtoms[i]->info(subSub);
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
#endif // PRINT || SPEC_PRINT

}

#endif // ADDITIONAL_ATOMS_WRAPPER_H
