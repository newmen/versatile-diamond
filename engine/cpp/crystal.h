#ifndef CRYSTAL_H
#define CRYSTAL_H

#include "common.h"
#include "vector3d.h"

namespace vd
{

class Atom;

class Crystal
{
public:
    typedef vector3d<Atom *> AtomsContainer;

    Crystal(const dim3 &sizes);
    virtual ~Crystal();

    virtual void initialize();

protected:
    virtual void buildAtoms() = 0;
    virtual void bondAllAtoms() = 0;

    void findAllSpecs();

//    Atom *atom(const uint3 &coords) { return _atoms[coords]; }
    AtomsContainer &atoms() { return _atoms; }

private:
    AtomsContainer _atoms;
};

}

#endif // CRYSTAL_H
