#ifndef TEMPLATED_CRYSTAL_H
#define TEMPLATED_CRYSTAL_H

#include "../atoms/saving_atom.h"
#include "../tools/common.h"

namespace vd
{

template
<
        template <class AtomType> class ContainerType,
        class AtomType
>
class TemplatedCrystal
{
    typedef ContainerType<AtomType> Atoms;

    Atoms _atoms;

public:
    virtual ~TemplatedCrystal();

    template <class L> void eachAtom(const L &lambda) const;

    const dim3 &sizes() const { return _atoms.sizes(); }

    virtual float3 correct(const SavingAtom *atom) const = 0;
    virtual float3 seeks(const int3 &coords) const = 0;
    virtual const float3 &periods() const = 0;

    uint maxAtoms() const;
    uint countAtoms() const;

protected:
    template <class... Args> TemplatedCrystal(Args... args);

    const Atoms &atoms() const { return _atoms; }
    Atoms &atoms() { return _atoms; }

private:
    TemplatedCrystal(const TemplatedCrystal &) = delete;
    TemplatedCrystal(TemplatedCrystal &&) = delete;
    TemplatedCrystal &operator = (const TemplatedCrystal &) = delete;
    TemplatedCrystal &operator = (TemplatedCrystal &&) = delete;
};

//////////////////////////////////////////////////////////////////////////////////////

template <template <class A> class V, class A>
template <class... Args>
TemplatedCrystal<V, A>::TemplatedCrystal(Args... args) : _atoms(args...)
{
}

template <template <class A> class V, class A>
TemplatedCrystal<V, A>::~TemplatedCrystal()
{
    eachAtom([](A *atom) {
        delete atom;
    });
}

template <template <class A> class V, class A>
template <class L>
void TemplatedCrystal<V, A>::eachAtom(const L &lambda) const
{
    _atoms.each([&lambda](A *atom) {
        if (atom)
        {
            lambda(atom);
        }
    });
}

template <template <class A> class V, class A>
uint TemplatedCrystal<V, A>::maxAtoms() const
{
    return _atoms.size();
}

template <template <class A> class V, class A>
uint TemplatedCrystal<V, A>::countAtoms() const
{
    int result = 0;
    eachAtom([&result](const A *) {
        ++result;
    });
    return result;
}

}

#endif // TEMPLATED_CRYSTAL_H

