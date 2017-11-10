#ifndef FAKE_ATOM_H
#define FAKE_ATOM_H

#include <../hand-generations/src/atoms/specified_atom.h>

class FakeAtom : public SpecifiedAtom<89>
{
public:
    FakeAtom(ushort type, ushort actives, Atom::OriginalLattice *lattice) :
        SpecifiedAtom(type, actives, lattice) {}

    const char *name() const final
    {
        static const char *name = "FakeAtom";
        return name;
    }
};

#endif // FAKE_ATOM_H
