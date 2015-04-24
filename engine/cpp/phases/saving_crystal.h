#ifndef SAVING_CRYSTAL_H
#define SAVING_CRYSTAL_H

#include "../atoms/saving_atom.h"
#include "templated_crystal.h"
#include "atoms_vector3d.h"
#include "crystal.h"

namespace vd
{

class SavingAtom;

class SavingCrystal : public TemplatedCrystal<AtomsVector3d, SavingAtom>
{
    const Crystal *_original;

public:
    SavingCrystal(const Crystal *original);

    void insert(SavingAtom *atom, const int3 &coords);

    uint countAtoms() const;

    template <class L> void eachSlice(const L &lambda) const;
    float3 translate(const int3 &coords) const;

    float3 correct(const SavingAtom *atom) const final;
    float3 seeks(const int3 &coords) const final;
    const float3 &periods() const final;

private:
    SavingCrystal(const SavingCrystal &) = delete;
    SavingCrystal(SavingCrystal &&) = delete;
    SavingCrystal &operator = (const SavingCrystal &) = delete;
    SavingCrystal &operator = (SavingCrystal &&) = delete;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class L>
void SavingCrystal::eachSlice(const L &lambda) const
{
    uint step = sizes().x * sizes().y;
    for (uint i = 0; i < sizes().N(); i += step)
    {
        lambda(atoms().data() + i);
    }
}

}

#endif // SAVING_CRYSTAL_H
