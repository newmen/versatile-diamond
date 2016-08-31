#include "saving_crystal.h"
#include "../atoms/saving_atom.h"

namespace vd
{

SavingCrystal::SavingCrystal(const Crystal *original) :
    TemplatedCrystal(original->sizes()), _original(original)
{
}

void SavingCrystal::insert(SavingAtom *atom, const int3 &coords)
{
    assert(!atom->lattice());
    assert(!atoms()[coords]);

    atom->setLattice(new Lattice<SavingCrystal>(this, coords));
    atoms()[coords] = atom;
}

float3 SavingCrystal::translate(const int3 &coords) const
{
    float3 realCoords = coords * periods();
    return realCoords + seeks(coords);
}

float3 SavingCrystal::correct(const SavingAtom *atom) const
{
    return _original->correct(atom);
}

float3 SavingCrystal::seeks(const int3 &coords) const
{
    return _original->seeks(coords);
}

const float3 &SavingCrystal::periods() const
{
    return _original->periods();
}

}
