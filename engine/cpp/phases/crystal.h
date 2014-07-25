#ifndef CRYSTAL_H
#define CRYSTAL_H

#include "../tools/common.h"
#include "atoms_vector3d.h"

namespace vd
{

class Atom;

class Crystal
{
    AtomsVector3d _atoms;

public:
    Crystal(const dim3 &sizes, const Behavior *behavior);
    virtual ~Crystal();

    void initialize();

    void changeBehavior (const Behavior *behavior);

    void insert(Atom *atom, const int3 &coords);
    void erase(Atom *atom);

    Atom *atom(const int3 &coords) { return _atoms[coords]; }

    uint countAtoms() const;
    const dim3 &sizes() const { return _atoms.sizes(); }

    void setUnvisited();
#ifndef NDEBUG
    void checkAllVisited();
#endif // NDEBUG

    template <class L> void eachSlice(const L &lambda) const;

    Atom *firstAtom() const { return _atoms.data()[0]; }
    float3 translate(const int3 &coords) const;

    virtual float3 correct(const Atom *atom) const = 0;
    virtual const float3 &periods() const = 0;

protected:
    virtual float3 seeks(const int3 &coords) const = 0;

    virtual void buildAtoms() = 0;
    virtual void bondAllAtoms() = 0;
    virtual void findAll() = 0;

    virtual Atom *makeAtom(ushort type, ushort actives, const int3 &coords) = 0;

    void makeLayer(uint z, ushort type, ushort actives);

    const AtomsVector3d &atoms() const { return _atoms; }
    AtomsVector3d &atoms() { return _atoms; }

private:
    Crystal(const Crystal &) = delete;
    Crystal(Crystal &&) = delete;
    Crystal &operator = (const Crystal &) = delete;
    Crystal &operator = (Crystal &&) = delete;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class L>
void Crystal::eachSlice(const L &lambda) const
{
    uint step = sizes().x * sizes().y;
    for (uint i = 0; i < sizes().N(); i += step)
    {
        lambda(_atoms.data() + i);
    }
}

}

#endif // CRYSTAL_H
