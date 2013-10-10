#ifndef CRYSTAL_H
#define CRYSTAL_H

#include "common.h"
#include "vector3d.h"
#include "atom.h"
#include "neighbours.h"

namespace vd
{

class AtomBuilder;

class Crystal
{
public:
    typedef vector3d<Atom *> AtomsContainer;

    Crystal(const dim3 &sizes);
    virtual ~Crystal();

    virtual void initialize();

    void insert(Atom *atom);
    void erase(Atom *atom);
    void remove(Atom *atom);

protected:
    virtual void buildAtoms() = 0;
    virtual void bondAllAtoms() = 0;

//    const IAtom *atom(const uint3 &coords) const { return _atoms[coords]; }
//    IAtom *atom(const uint3 &coords) { return _atoms[coords]; }

    AtomsContainer &atoms() { return _atoms; }

    void makeLayer(AtomBuilder *builder, uint z, uint type);

private:
    void findAllSpecs();

private:
    AtomsContainer _atoms;
};

}

#endif // CRYSTAL_H
