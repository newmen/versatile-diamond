#ifndef CRYSTAL_H
#define CRYSTAL_H

#include "../tools/common.h"
#include "templated_crystal.h"
#include "smart_atoms_vector3d.h"

namespace vd
{

class Atom;

class Crystal : public TemplatedCrystal<SmartAtomsVector3d, Atom>
{
public:
    void initialize();

    void changeBehavior (const Behavior *behavior);

    void insert(Atom *atom, const int3 &coords);
    void erase(Atom *atom);

    Atom *atom(const int3 &coords) { return atoms()[coords]; }

protected:
    Crystal(const dim3 &sizes, const Behavior *behavior);

    virtual void buildAtoms() = 0;
    virtual void bondAllAtoms() = 0;
    virtual void findAll() = 0;

    virtual Atom *makeAtom(ushort type, ushort actives, const int3 &coords) = 0;

    void makeLayer(uint z, ushort type, ushort actives);
};

}

#endif // CRYSTAL_H
