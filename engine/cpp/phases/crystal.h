#ifndef CRYSTAL_H
#define CRYSTAL_H

#include "../tools/common.h"
#include "../tools/vector3d.h"

namespace vd
{

class Atom;

class Crystal
{
    typedef vector3d<Atom *> Atoms;
    Atoms _atoms;

public:
    Crystal(const dim3 &sizes);
    virtual ~Crystal();

    void initialize();

    void insert(Atom *atom, const int3 &coords);
    void erase(Atom *atom);

    Atom *atom(const int3 &coords) const { return _atoms[coords]; }

    uint countAtoms() const;
    const dim3 &sizes() const { return _atoms.sizes(); }

    void setUnvisited();
#ifndef NDEBUG
    void checkAllVisited();
#endif // NDEBUG

    Atom *firstAtom() const { return _atoms.data()[0]; }
    float3 translate(const int3 &coords) const;

    virtual const float3 &periods() const = 0;

protected:
    virtual float3 seeks(const int3 &coords) const = 0;

    virtual void buildAtoms() = 0;
    virtual void bondAllAtoms() = 0;
    virtual void findAll() = 0;

    virtual Atom *makeAtom(uint type, const int3 &coords) = 0;

    void makeLayer(uint z, uint type);

    const Atoms &atoms() const { return _atoms; }
    Atoms &atoms() { return _atoms; }

private:
    Crystal(const Crystal &) = delete;
    Crystal(Crystal &&) = delete;
    Crystal &operator = (const Crystal &) = delete;
    Crystal &operator = (Crystal &&) = delete;
};

}

#endif // CRYSTAL_H
