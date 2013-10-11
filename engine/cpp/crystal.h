#ifndef CRYSTAL_H
#define CRYSTAL_H

#include "common.h"
#include "vector3d.h"
#include "atom.h"

namespace vd
{

class Crystal
{
public:
    typedef vector3d<Atom *> Atoms;

    Crystal(const dim3 &sizes);
    virtual ~Crystal();

    void initialize();
    void insert(Atom *atom, const int3 &coords);
    void erase(Atom *atom);
    void remove(Atom *atom);

//    const Atom *atom(const int3 &coords) const { return _atoms[coords]; }

    uint countAtoms() const;

protected:
    virtual void buildAtoms() = 0;
    virtual void bondAllAtoms() = 0;
    virtual Atom *makeAtom(uint type, const int3 &coords) = 0;

    void makeLayer(uint z, uint type);

//    Atom *atom(const int3 &coords) { return _atoms[coords]; }

    const Atoms &atoms() const { return _atoms; }
    Atoms &atoms() { return _atoms; }

private:
    void findAllSpecs();

private:
    Atoms _atoms;
};

}

#endif // CRYSTAL_H
