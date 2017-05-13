#ifndef SAVING_ATOM_H
#define SAVING_ATOM_H

#include <vector>
#include "base_atom.h"

namespace vd
{

class Atom;
class SavingCrystal;

class SavingAtom : public BaseAtom<SavingAtom, SavingCrystal>
{
    typedef BaseAtom<SavingAtom, SavingCrystal> ParentType;

    const char *_name;
    ushort _valence;

    typedef Lattice<SavingCrystal> OriginalLattice;

public:
    SavingAtom(const Atom *original, OriginalLattice *lattice);

    void setLattice(OriginalLattice *lattice);

    const char *name() const override { return _name; }
    ushort valence() const override { return _valence; }

    float3 realPosition() const;

    SavingAtom *firstCrystalNeighbour() const;
    ushort crystalNeighboursNum() const;

private:
    SavingAtom(const SavingAtom &) = delete;
    SavingAtom(SavingAtom &&) = delete;
    SavingAtom &operator = (const SavingAtom &) = delete;
    SavingAtom &operator = (SavingAtom &&) = delete;

    float3 relativePosition() const;
    float3 correctAmorphPos() const;
    std::vector<const SavingAtom *> goodCrystalRelatives() const;
};

}

#endif // SAVING_ATOM_H
